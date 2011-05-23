require File.join(File.dirname(__FILE__), 'movie')
require File.join(File.dirname(__FILE__), 'poster')

class MovMonster
  def initialize(config, opts)
    @config, @opts = config, opts

    DataMapper.setup(:default, @config['database'])
    $logger.debug("Using database: #{@config['database']}")
    DataMapper.finalize
  end

  def run(dry = false)
    Movie.all.each do |movie|
      next if !movie.posters.nil? && movie.posters.length > 0
      movie.download_posters(@config['covers'])
    end
  end
end
