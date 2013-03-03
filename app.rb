require 'sinatra'
require 'sequel'
require 'sequel/extensions/migration'

require 'haml'
require 'redcarpet'

class Doi2Oa < Sinatra::Base

  puts 'before configure blocks'
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
  end

  get '/' do
    markdown :index
  end

  get '/resolve' do
    return Doi.resolve(params["doi"]) || "unavailable" if params.has_key?("doi")
    redirect to('/')
  end

  get '/redirect' do
    loc = url('/')
    if params.has_key?("doi")
      loc = Doi.resolve(params["doi"]) || loc
    end
    redirect loc
  end

  run! if app_file == $0

end
