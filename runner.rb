#!/usr/bin/env ruby

require 'rubygems'
require 'trollop'

require File.join(File.dirname(__FILE__), 'src/configurator')
require File.join(File.dirname(__FILE__), 'src/movmonster')

COMMANDS = %w(fill prune scan relink)

opts = Trollop::options do
  banner <<-EOS
usage: #{__FILE__} <command> [options]

Possible commands:

   fill       Scan the database, filling in missing posters
   prune      Remove movies with no matching file from the database
   scan       Look for new movies on the filesystem
   relink     Ensure symlinks exist for all movies in the database

global options:
EOS
  opt :config,    "Load configuration from this file",
      :default => File.join( File.dirname(__FILE__), 'config.yml')
  opt :debug,     "Print more output", :default => false
  opt :stdout,    "Print log to stdout", :default => false
  opt :env,       "Use specified environment for configuration", :default => 'production'
  opt :create_dirs, "Create necessary directories for symlinks", :default => true
  stop_on COMMANDS
end

cmd = ARGV.shift

Trollop::die :config, "must exist" unless File.exist?(opts[:config])

# Load in config.yml file
Configurator.load_yaml(opts[:config], opts[:env])
# Load in runtime options
Configurator.merge!(opts)
Configurator.setup!

monster = MovMonster.new

if COMMANDS.include?(cmd) && monster.respond_to?(cmd)
  monster.send cmd
else
  STDERR.puts "Unknown command '#{cmd}'"
end
