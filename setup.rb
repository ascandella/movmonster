#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'data_mapper'
require 'dm-postgres-adapter'
require 'logger'
require 'ruby-tmdb'

%w{configurator movmonster}.map do |f|
  require File.join(File.dirname(__FILE__), 'src', f)
end


# DataMapper is unforgiving with migrations
$stderr.puts ">> This will overwrite any existing data you have in the movmonster database!
   Only run this the first time you install the program.

   (hit enter to continue, control-c to cancel)"

gets

%w{development test production}.each do |environment|
  Configurator.clear!
  Configurator.load_yaml(File.join(File.dirname(__FILE__), 'config.yml'), environment)
  Configurator.merge!(:stdout => true)
  Configurator.setup!

  monster = MovMonster.new
  monster.migrate!
end

$stdout.puts "Success!"
