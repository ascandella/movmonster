#!/usr/bin/env ruby

require 'rubygems'
require 'trollop'
require 'yaml'
require 'sqlite3'
require File.join(File.dirname(__FILE__), '/lib/movmonster')

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
  opt :debug,     "Print more output",
      :default => false
  stop_on COMMANDS
end

cmd = ARGV.shift
dryrun = cmd == 'dryrun'

Trollop::die :config, "must exist" unless File.exist?(opts[:config])
config = YAML::load(File.open(opts[:config]))

db = SQLite3::Database.new(File.join(File.dirname(__FILE__), config['database']['location']))

monster = MovMonster.new(config, opts, db)
monster.run(dryrun)
