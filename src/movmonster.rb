%w{ignore movie poster}.map do |f|
  require File.join(File.dirname(__FILE__), 'models', f)
end

class MovMonster
  def initialize
    DataMapper.finalize
  end

  def fill
    Movie.all.each do |movie|
      next if !movie.posters.nil? && movie.posters.length > 0
      movie.download_posters(Configurator['covers'])
    end
  end

  def lookup_movie(filename)
    base_filename = File.basename(filename)
    base_parts = base_filename.split('.')
    if base_parts.length > 1
      base_parts = base_parts[(0..(base_parts.length-2))]
    end
    base_name = base_parts.join(" ")

    # Check to see if it's a bad title so we don't hammer TMDB
    if Ignore.count(:filename => filename) > 0 ||
        Movie.count(:filename => filename) > 0
      return
    end

    Configurator.log.info "Looking up '#{base_name}'"
    opts = {:title => base_name, :limit => (Configurator[:first_match] ? 1 : 10)}
    begin
      movie = find_best_match(opts, filename)
    rescue => ex
      Configurator.log.error "Couldn't look up movie: #{base_name}... #{ex.inspect}"
      return
    end
    if movie
      add_match(movie, File.join(Configurator[:base_dir], filename))
      movie.download_posters(Configurator['covers'])
    end
    movie
  end

  def scan
    Configurator.log.debug "Scanning directory: #{Configurator['base_dir']}"
    Dir.glob(File.join(Configurator[:base_dir], "*.{avi,mkv}")) do |filename|
      lookup_movie(filename)
    end
    Configurator.log.debug "Finished scan"
  end

  def prune
    Movie.all.each do |movie|
      unless File.exist? movie.filename
        Configurator.log.warn "Removing #{movie.name} at #{movie.filename}"
        movie.posters.destroy
        movie.destroy
      end
    end
  end

  def relink
    Movie.all.each do |movie|
      movie.create_links
    end
  end

  # Be careful about calling this. Better yet, don't.
  def migrate!
    DataMapper.auto_migrate!
  end

private
  def find_best_match(opts, filename)
    matches = TmdbMovie.find opts
    if (matches.nil?)
      Configurator.log.error "Could not find TMDB info for '#{opts[:title]}'. Ignoring."
      Ignore.create :filename => filename
      return
    end

    if (matches.is_a? Array)
      matches.select! {|m| m.name.downcase.gsub(/^(the)|(a) /, '') == opts[:title].downcase}
      if Configurator[:first_match] || matches.length == 0
        Configurator.log.info "Got #{matches.length} results, ignoring"
        Ignore.create :filename => filename
        return
      else
        if (!matches.nil? && matches.length == 1)
          Configurator.log.debug("Found exact title match")
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
        Configurator.log.info "Using #{matches.name} #{matches.released}"
      end
    end

    return Movie.parse_from_tmdb(matches)
  end

  def add_match(movie, filename)
    Configurator.log.debug "Adding match: #{filename}"
    movie.filename = filename
    movie.create_links
    movie.save
  end
end
