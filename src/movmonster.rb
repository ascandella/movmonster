require File.join(File.dirname(__FILE__), 'models')

class MovMonster
  def initialize(config, opts)
    @config, @opts = config, opts

    DataMapper.setup(:default, @config['database'])
    $logger.debug("Using database: #{@config['database']}")
    DataMapper.finalize
    @cover_location = File.join(File.dirname(__FILE__), '..', @config['covers']['location'])
  end

  def run(dry)
    Movie.all(:poster => false).each do |movie|
      movie.download_best_image(@config['covers']['size'], @cover_location)
      break
    end
  end

end
