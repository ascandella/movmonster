#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'data_mapper'
require 'dm-postgres-adapter'
require 'logger'
require 'net/http'
require 'ruby-tmdb'
require 'trollop'
require 'yaml'

require File.join(File.dirname(__FILE__), 'src/movmonster')

COMMANDS = %w(fill prune scan)

opts = Trollop::options do
  banner <<-EOS
usage: #{__FILE__} <command> [options]

Possible commands:

   fill       Scan the database, filling in missing posters
   prune      Remove movies with no matching file from the database
   scan       Look for new movies on the filesystem

global options:
EOS
  opt :config,    "Load configuration from this file",
      :default => File.join( File.dirname(__FILE__), 'config.yml')
  opt :debug,     "Print more output", :default => false
  opt :stdout,    "Print log to stdout", :default => false
  opt :create_dirs, "Create necessary directories for symlinks", :default => true
  stop_on COMMANDS
end

cmd = ARGV.shift

Trollop::die :config, "must exist" unless File.exist?(opts[:config])
config = YAML::load(File.open(opts[:config]))

log_file = opts[:stdout] ? $stdout : File.open(config['log'], 'w+')
log_level = opts[:debug] ? :debug  : :info
$logger = Logger.new(log_file, log_level)
DataMapper::Logger.new(log_file, log_level) 

Tmdb.api_key = config['tmdb_key']

monster = MovMonster.new(config, opts)
case cmd
when 'fill'
  monster.fill_posters
when 'prune'
  monster.prune
when 'scan'
  monster.scan_for_movies
else
  STDERR.puts "Unknown command '#{cmd}'"
end
