require File.join(File.dirname(__FILE__), 'movie')

class MovMonster
  def initialize(config, opts)
    @config, @opts = config, opts

    DataMapper.setup(:default, @config['database'])
    $logger.debug("Using database: #{@config['database']}")
    DataMapper.finalize
    @cover_location = @config['covers']['location']
  end

  def run(dry = false)
    Movie.all(:poster => false).each do |movie|
      movie.download_best_image(@config['covers']['size'], @cover_location)
    end
  end

end
