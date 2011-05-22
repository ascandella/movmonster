#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'haml'
require 'coffee_script'

get '/' do
  haml :index
end

get '/:name.js' do |name|
  coffee name.to_sym
end

get '/:name.css' do |name|
  sass name.to_sym
end
