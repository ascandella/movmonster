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

  def thumbnail
    ps = posters.detect{ |p| p.size == 'w154' }
    if ps.nil?
      ps = posters.first
    end
    return ps
  end

  def genre_map
    h = {'data-id' => id}
    self.genres.split(',').each{ |g| h[ "data-#{g.downcase}"] = true }
    h
  end

  def download_posters(sizes)
    $logger.info("Fetching cover for #{self.name}")
    begin
      tm = TmdbMovie.images({:imdb => self.imdb_id})
    rescue => ex
      $logger.error("Error fetching info fon movie #{self.name}: #{ex.inspect}")
      return
    end
    if tm.nil?
      $logger.warn("Movie not found!")
      return
    end
    if tm['posters'].nil? || tm['posters'].length < 1
      $logger.warn("No covers found!")
      return
    end

    posters = tm['posters'].select{ |m| m['image']['type'] == 'poster' }
    if posters.nil? || posters.length == 0
      $logger.warn("No covers of type 'poster' found. Bailing.")
      return
    end

    sizes.each do |size, location|
      save_image(size, location, posters.detect do |p|
        p['image']['size'] == size
      end)
    end
  end

private
  def save_image(size, location, poster)
    $logger.warn("No image to save") and return if poster.nil?
    url = poster['image']['url']
    begin
      uri = URI.parse(url)
    rescue
      $logger.warn("Couldn't parse URL #{url}!")
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

    if File.exists? abs_path
      $logger.info "Found existing thumb at location #{abs_path}. " +
                   "If you with to re-fetch it, please delete the original."
      self.posters.create :location => abs_path, :size => size,
        :width => poster['image']['width'], :height => poster['image']['height']
      return
    end

    Net::HTTP.start(uri.host) do |http|
      resp = http.get(uri.path)
      open(abs_path, 'wb') do |file|
        file.write(resp.body)
      end
    end
    $logger.debug("Saved cover to #{abs_path}")
    self.posters.create :location => abs_path,
      :width => poster['image']['width'], :height => poster['image']['height']
  end

  @@path_regex = /.*\.([^.]+)/
  @@name_regex = /.*\/([^\/]+)/
end
