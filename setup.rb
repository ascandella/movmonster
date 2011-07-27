#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'data_mapper'
require 'dm-postgres-adapter'
require 'logger'
require 'ruby-tmdb'
require 'yaml'

require File.join(File.dirname(__FILE__), 'src/configurator')
require File.join(File.dirname(__FILE__), 'src/movmonster')


Configurator.load_yaml(File.join( File.dirname(__FILE__), 'config.yml'))
Configurator.merge!(:stdout => true)
Configurator.setup!

# DataMapper is unforgiving with migrations
$stderr.puts ">> This will overwrite any existing data you have in the movmonster database!
   Only run this the first time you install the program.

   (hit enter to continue, control-c to cancel)"

gets
$stdout.puts "Success!"

monster = MovMonster.new
monster.migrate!
