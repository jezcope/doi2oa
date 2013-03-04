require 'sinatra'
require 'sequel'
require 'sequel/extensions/migration'

require 'haml'
require 'maruku'

class Doi2Oa < Sinatra::Base

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

    require_relative 'models/doi'
    require_relative 'models/repository'

    set :haml,      layout: :layout
    set :markdown,  layout: :layout, layout_engine: :haml
    set :root,      File.dirname(__FILE__)
  end

  get '/' do
    markdown :index
  end

  get %r{/resolve/?(?<doi_capture>.+)?} do
    unless doi = params[:doi] || params[:doi_capture]
      error 400
    end
    if dest = Doi.resolve(doi)
      return dest
    end
    error 404
  end

  get %r{/redirect/?(?<doi_capture>.+)?} do
    unless doi = params[:doi] || params[:doi_capture]
      error 400
    end
    if dest = Doi.resolve(doi)
      redirect dest
    end
    error 404
  end

  run! if app_file == $0

end
