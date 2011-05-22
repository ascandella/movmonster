class Movie
  include DataMapper::Resource

  property :filename, FilePath, :key => true
  property :name,     String
  property :genres,   Text
  property :year,     Integer
  property :rating,   Float
  property :director, Text
  property :imdb_id,  String
  property :certification, String
  property :poster,   FilePath

  def web_url
    self.poster.to_s.gsub('web/public/', '')
  end

  def download_best_image(size, location)
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

    save_image(location, posters.detect do |p|
      p['image']['size'] == size
    end)
  end

private
  def save_image(location, poster)
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
      self.update :poster => abs_path
    end

    Net::HTTP.start(uri.host) do |http|
      resp = http.get(uri.path)
      open(abs_path, 'wb') do |file|
        file.write(resp.body)
      end
    end
    $logger.debug("Saved cover to #{abs_path}")
    self.update :poster => abs_path
  end

  @@path_regex = /.*\.([^.]+)/
  @@name_regex = /.*\/([^\/]+)/
end
