module MovMonster
  class Movie
    include DataMapper::Resource

    property :id,       Serial
    property :filename, FilePath
    property :name,     Text
    property :genres,   Text
    property :year,     Integer
    property :rating,   Float
    property :director, Text
    property :imdb_id,  String
    property :certification, String

    has n, :posters

    def decade
      year - (year % 10) if year
    end

    def thumbnail
      @thumbnail ||= posters.detect{ |p| p.size == 'w154' }
    end

    # Yea, not really model-level logic, I know
    def attr_map 
      h = {
        'data-id' => id,
        'data-posters' => (@posters || []).map do |p|
          p.attributes.merge(:web_location => p.href)
        end.to_json,
        'data-year' => @year,
        'class' => (thumbnail() ? 'withPoster lazyLoadNeeded' : 'noPoster')
      }
      h['data-thumb-src'] = thumbnail.href if thumbnail
      genres.split(',').reduce(h){ |ha, g| ha["data-category-#{g.downcase.gsub(' ', '_')}"] = true; ha }
    end

    def download_posters(sizes)
      unless @tmdb_posters
        Configurator.log.info("Fetching cover for #{self.name}")
        begin
          tm = TmdbMovie.images({:imdb => self.imdb_id})
        rescue => ex
          Configurator.log.error("Error fetching info for movie #{self.name}: #{ex.inspect}")
          return
        end

        return Configurator.log.warn("Movie not found!") if tm.nil?
      end
      @tmdb_posters = tm['posters']
      process_posters(sizes)
    end

    def self.parse_from_tmdb(m)
      mov = Movie.new
      mov.rating = m.rating.to_s
      mov.genres = m.genres.map{ |g| g.name }.join(',') if m.genres
      mov.year = Date.parse(m.released).year if m.released

      directors = m.cast.select{ |c| c.job == 'Director' }
      mov.director = directors.first.name if directors && directors.first
      # Copy over the rest straight
      mov.imdb_id, mov.certification, mov.name = m.imdb_id, m.certification, m.name
      @tmdb_posters = m.posters
      return mov
    end

    def create_links
      dirname = File.dirname(@filename)
      filename = File.basename(@filename)

      Configurator[:categories].each do |category, directory|
        # See if we have any info available for this category
        folders = self[category]
        next if folders.nil?

        folders.to_s.split(',').each do |folder|
          dest_dir = File.join(Configurator[:destination_dir],
             directory, folder.to_s)

          if Configurator[:create_dirs] && !File.exists?(dest_dir)
            FileUtils.mkdir_p(dest_dir)
          end

          target = File.join(dest_dir, filename)
          if File.symlink?(target)
            Configurator.log.debug("Skipping link creation for #{target}, as it already exists")
            next
          end

          Configurator.log.debug("Creating link to #{target}")

          if !File.symlink( @filename, target )
              Configurator.log.error("Coouldn't symlink #{filename} from #{Configurator['base_dir']} to #{target}")
          end
        end
      end
    end

    def [] (name)
      if self.respond_to?(name.to_sym)
        return self.send(name.to_sym)
      end
    end

    # For tests
    def exist?
      true
    end

  private

    def process_posters(sizes)
      if @tmdb_posters.nil? || @tmdb_posters.length < 1
        Configurator.log.warn("No covers found!")
        return
      end

      posters = @tmdb_posters.select{ |m| m['image']['type'] == 'poster' }
      if posters.nil? || posters.length == 0
        Configurator.log.warn("No covers of type 'poster' found. Bailing.")
        return
      end

      sizes.each do |size, location|
        save_image(size, location, posters.detect do |p|
          p['image']['size'] == size
        end)
      end
    end

    def save_image(size, location, poster)
      Configurator.log.warn("No image to save") and return if poster.nil?
      url = poster['image']['url']
      begin
        uri = URI.parse(url)
      rescue
        Configurator.log.error("Couldn't parse URL #{url}!")
        return
      end

      extension_match = @@path_regex.match(uri.path)
      # Try to save it as #{imdb_id}.#{extension}
      if extension_match[1]
        save_location = "#{self.imdb_id}.#{extension_match[1]}"
      else
        # We can't determine the extension, use the original name
        save_location = "#{@@name_regex.match(uri.path)[1]}"
      end
      abs_path = File.join(location, save_location)

      # Save the poster and link ot to this movie
      self.posters.create :location => abs_path, :size => size,
        :width => poster['image']['width'], :height => poster['image']['height']

      if File.exists? abs_path
        Configurator.log.info "Found existing thumb at location #{abs_path}. " +
                     "If you with to re-fetch it, please delete the original."
        return
      end

      Net::HTTP.start(uri.host) do |http|
        resp = http.get(uri.path)
        open(abs_path, 'wb') do |file|
          file.write(resp.body)
        end
      end
      Configurator.log.debug("Saved cover to #{abs_path}")
    end

    @@path_regex = /.*\.([^.]+)/
    @@name_regex = /.*\/([^\/]+)/
  end
end
