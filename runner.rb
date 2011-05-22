#!/usr/bin/env ruby

require 'rubygems'

require 'data_mapper'
require 'dm-sqlite-adapter'
require 'logger'
require 'ruby-tmdb'
require 'trollop'
require 'yaml'

require File.join(File.dirname(__FILE__), '/src/movmonster')

COMMANDS = %w(fill dryrun)

opts = Trollop::options do
  banner <<-EOS
usage: #{__FILE__} <command> [options]

Possible commands:

   fill       Scan the database, filling in missing info
   dryrun     Don't actually do anything, just print debug info

global options:
EOS
  opt :config,    "Load configuration from this file",
      :default => File.join( File.dirname(__FILE__), 'config.yml')
  opt :debug,     "Print more output", :default => false
  opt :stdout,    "Print log to stdout", :default => false
  stop_on COMMANDS
end

cmd = ARGV.shift
dryrun = cmd == 'dryrun'

Trollop::die :config, "must exist" unless File.exist?(opts[:config])
config = YAML::load(File.open(opts[:config]))

log_file = opts[:stdout] ? $stdout : File.open(config['log'], 'w+')
log_level = opts[:debug] ? :debug  : :info
$logger = Logger.new(log_file, log_level)
DataMapper::Logger.new(log_file, log_level) 

Tmdb.api_key = config['tmdb_key']

monster = MovMonster.new(config, opts)
monster.run(dryrun)
