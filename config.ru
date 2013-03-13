require 'rubygems'
require 'bundler'
Bundler.require

require './app.rb'

map Doi2Oa.assets_path do
  run Doi2Oa.sprockets
end

map '/' do
  run Doi2Oa
end
