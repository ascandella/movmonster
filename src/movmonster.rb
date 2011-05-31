require File.join(File.dirname(__FILE__), 'movie')
require File.join(File.dirname(__FILE__), 'poster')

class MovMonster
  def initialize(config, opts)
    @config, @opts = config, opts
    DataMapper.setup(:default, @config['database'])
    $logger.debug("Using database: #{@config['database']}")
    DataMapper.finalize
  end

  def fill_posters
    Movie.all.each do |movie|
      next if !movie.posters.nil? && movie.posters.length > 0
      movie.download_posters(@config['covers'])
    end
  end

  def scan_for_movies
    Dir.glob(File.join(@config['base_dir'], "*.{avi,mkv}")) do |filename|
      base_filename = File.basename(filename)
      base_parts = base_filename.split('.')
      if base_parts.length > 1
        base_parts = base_parts[(0..(base_parts.length-2))]
      end
      base_name = base_parts.join(" ")

      $logger.debug "Filename: #{filename}"

      # Check to see if it's a bad title so we don't hammer TMDB
      if Ignore.count(:filename => filename) > 0 ||
         Movie.count(:filename => filename) > 0
        next
      end

      $logger.info "Looking up '#{base_name}'"
      opts = {:title => base_name, :limit => (@first_match ? 1 : 10)}
      movie = find_best_match(opts, filename)
      if movie
        add_match(movie, filename, base_filename)
        movie.download_posters(@config['covers'])
      end
    end
  end

  def prune
    Movie.all.each do |movie|
      unless File.exist? movie.filename
        $logger.warn "Removing #{movie.name} at #{movie.filename}"
        movie.posters.destroy
        movie.destroy
      end
    end
  end

private
  def find_best_match(opts, filename)
    matches = TmdbMovie.find opts
    if (matches.nil?)
      $logger.error "Could not find TMDB info for '#{opts[:title]}'. Ignoring."
      Ignore.create :filename => filename
      return
    end

    if (matches.is_a? Array)
      matches.select! {|m| m.name.downcase.gsub(/^(the)|(a) /, '') == opts[:title].downcase}
      if @opts[:first_match] || matches.length == 0
        $logger.info "Got #{matches.length} results, ignoring"
        return Ignore.create :filename => filename
      else
        if (!matches.nil? && matches.length == 1)
          $logger.debug("Found exact title match")
          matches = matches.first
        else
          puts "Need clarification for #{opts[:title]}"
          matches.each_with_index do |m, i|
            puts "#{i}) #{m.name} #{m.released}"
          end

          index = -1
          while (index == -1 || index > matches.length) do
            puts "?"
            index = gets().chomp.to_i
            return Ignore.create :filename => filename if index == -2
          end
          matches = matches[index]
        end
        $logger.info "Using #{matches.name} #{matches.released}"
      end
    end

    return Movie.parse_from_tmdb(matches)
  end

  def add_match(m, filename, base_filename)
    $logger.info "Adding match: #{base_filename}"

    @config['categories'].each do |category, directory|
      # Grab the info from the movie object
      folders = m[category]
      next if folders.nil?

      if !folders.is_a?(Array)
        folders = [folders]
      end
      folders.each do |folder|
        full_folder = File.join(@config['destination_dir'],
           directory, folder.to_s)
        create_link(@config['base_dir'], full_folder,
            base_filename, base_filename)
        # TODO: Intelligent rename? Could get us into trouble
      end
    end
    m.filename = filename
    m.save
  end

  def create_link(source_dir, dest_dir, filename, dest_filename = nil)
    # Default to the original filename
    dest_filename ||= filename
    if @opts[:create_dirs] && !File.exists?(dest_dir)
      FileUtils.mkdir_p(dest_dir)
    end

    exec_str = "ln -s \"#{File.join(source_dir, filename)}\" \"" +
      File.join(dest_dir, dest_filename) + "\""
    if (!system(exec_str))
      $logger.error("Could not execute command: #{exec_str}")
    end
  end
end
