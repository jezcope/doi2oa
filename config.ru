require 'rubygems'
require 'bundler'
require 'pp'
Bundler.setup

require './app.rb'

map '/assets' do
  environment = Sprockets::Environment.new
  %w{images javascripts stylesheets}.each do |type|
    environment.append_path File.join(Compass::Frameworks['bootstrap'].path, 'vendor', 'assets', type)
    environment.append_path File.join('assets', type)
  end
  # environment.js_compressor = Uglifier.new(:copyright => false)
  # environment.css_compressor = YUI::CssCompressor.new
  environment.context_class.class_eval do
    def asset_path(path, options = {})
      File.join('/assets', path)
    end
  end
  run environment
end

map '/' do
  run Doi2Oa
end
