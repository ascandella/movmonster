#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'coffee_script'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'sass/plugin'

base_name = File.join(File.dirname(__FILE__), '../src/')
require File.join(base_name, 'models/ignore')
require File.join(base_name, 'models/movie')
require File.join(base_name, 'models/poster')
require File.join(base_name, 'models/request')

config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))

DataMapper::Logger.new($stdout, :info)
DataMapper.setup(:default, config['database'])
DataMapper.finalize

get '/' do
  @movies = Movie.all :order => [ :name.asc ]
  @cats   = config['web_categories']
  @min_year = (Movie.first :order => [ :year.asc ]).year
  @max_year = (Movie.first :year.gt => @min_year , :order => [ :year.desc ]).year || @min_year
  haml :index
end

get '/:name.js' do |name|
  coffee name.to_sym
end

get '/:name.css' do |name|
  sass name.to_sym
end
