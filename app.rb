require 'sinatra'
require 'sequel'
require 'sequel/extensions/migration'

require 'sprockets'

require 'haml'
require 'maruku'
require 'sass'
require 'compass'
require 'bootstrap-sass'
require 'yui/compressor'

class Doi2Oa < Sinatra::Base

  configure do
    set :root,      File.dirname(__FILE__)

    set :haml,      format: :html5, layout: :layout
    set :scss,      style: :compact, debug_info: false
    set :markdown,  layout: :layout, layout_engine: :haml

    set :assets_path, '/assets'

    environment = Sprockets::Environment.new
    %w{images javascripts stylesheets}.each do |type|
      environment.append_path File.join(Compass::Frameworks['bootstrap'].path, 'vendor', 'assets', type)
      environment.append_path File.join('assets', type)
    end

    environment.js_compressor = YUI::JavaScriptCompressor.new
    environment.css_compressor = YUI::CssCompressor.new

    environment.context_class.class_eval do
      def asset_path(path, options = {})
        File.join(Doi2Oa.assets_path, path)
      end
    end

    set :sprockets, environment
  end

  configure :development, :production do
    DB = Sequel.connect(ENV['DATABASE_URL'] \
                        || "sqlite://tmp/#{settings.environment}.sqlite")
  end

  configure :test do
    DB = Sequel.sqlite
  end

  configure do
    Sequel::Migrator.apply(DB, 'db/migrations')
    Sequel::Model.db = DB

    require_relative 'models/doi_mapping'
    require_relative 'models/repository'

    Compass.add_project_configuration(File.join(root, 'config', 'compass.rb'))
  end

  helpers do

    alias_method :h, :escape_html

    def menu_class(link_path)
      request.path_info == link_path ? {class: 'active'} : {}
    end

    def ga_id
      ENV['GA_ID'] || ''
    end

  end

  get '/' do
    markdown :index
  end

  get '/about' do
    markdown :about
  end

  get '/repositories' do
    @repositories = Repository.all
    haml :repositories
  end

  get %r{/resolve/?(?<doi_capture>.+)?} do
    unless doi = params[:doi] || params[:doi_capture]
      error 400
    end
    if dest = DoiMapping.resolve(doi)
      return dest
    end
    error 404
  end

  get %r{/redirect/?(?<doi_capture>.+)?} do
    unless doi = params[:doi] || params[:doi_capture]
      error 400
    end
    if dest = DoiMapping.resolve(doi)
      redirect dest
    end
    error 404
  end

  run! if app_file == $0

end
