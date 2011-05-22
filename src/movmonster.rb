require File.join(File.dirname(__FILE__), 'models')

class MovMonster
  def initialize(config, opts)
    @config, @opts = config, opts

    DataMapper.setup(:default, @config['database'])
    $logger.debug("Using database: #{@config['database']}")
    DataMapper.finalize
  end

  def run(dry)
    $logger.debug(Movie.all)
    Movie.all.each do |movie|
    end
  end
end
