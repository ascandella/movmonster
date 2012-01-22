#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'haml'
require 'coffee_script'
require 'data_mapper'
require 'dm-postgres-adapter'
require 'sass/plugin'
require 'json'

base_name = File.join(File.dirname(__FILE__), '../src/')
require File.join(base_name, 'models/ignore')
require File.join(base_name, 'models/movie')
require File.join(base_name, 'models/poster')
require File.join(base_name, 'models/request')

environment = ENV['RACK_ENV'] || :development
config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))[environment.to_s]

DataMapper::Logger.new($stdout, :info)
adapter = DataMapper.setup(:default, config['database'])
adapter.resource_naming_convention = DataMapper::NamingConventions::Resource::UnderscoredAndPluralizedWithoutModule
DataMapper.finalize

get '/' do
  @movies = MovMonster::Movie.all :order => [ :name.asc ]
  @cats   = config['web_categories']
  @min_year = (MovMonster::Movie.first :order => [ :year.asc ]).year
  @max_year = (MovMonster::Movie.first :year.gt => @min_year , :order => [ :year.desc ]).year || @min_year
  haml :index
end

get '/:name.js' do |name|
  coffee name.to_sym
end

get '/:name.css' do |name|
  sass name.to_sym
end
