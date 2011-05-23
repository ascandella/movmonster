#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'haml'
require 'coffee_script'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'sass/plugin'

require File.join(File.dirname(__FILE__), '../src/movie')
require File.join(File.dirname(__FILE__), '../src/poster')

config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))

DataMapper::Logger.new($stdout, :info)
DataMapper.setup(:default, config['database'])
DataMapper.finalize

get '/' do
  @movies = Movie.all :order => [ :name.asc ]
  haml :index
end

get '/:name.js' do |name|
  coffee name.to_sym
end

get '/:name.css' do |name|
  sass name.to_sym
end
