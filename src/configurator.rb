require 'rubygems'
require 'bundler/setup'

require 'yaml'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'logger'
require 'net/http'
require 'ruby-tmdb'

# A really dumb singleton-esque config manager
class Configurator
  def self.load_yaml(filename, environment = 'production')
    @@yams = YAML.load_file(filename)[environment]
  end

  def self.setup!
    if self[:stdout]
      file = $stdout
    else
      if self['log'].nil?
        $stderr.puts "WARNING: No log file configured, using stderr"
        file = $stderr
      else
        file = File.open(self['log'], 'a')
      end
    end

    level    = self[:debug] ? :debug : :info
    @@logger = Logger.new file, level

    DataMapper::Logger.new(file, level)
    DataMapper.setup(:default, self['database'])
    Tmdb.api_key = self['tmdb_key']
  end

  def self.merge!(hash)
    @@yams.merge!(hash)
  end

  def self.[] key
    @@yams.has_key?(key.to_s) ? @@yams[key.to_s] : @@yams[key.to_sym]
  end

  def self.log
    @@logger
  end

  def self.clear!
    @@yams = @@logger = nil
  end
end
