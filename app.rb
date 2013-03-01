require 'sinatra'
require 'sequel'

require 'haml'
require 'redcarpet'

require_relative 'db/init'

require_relative 'models/doi'
require_relative 'models/repository'

class Doi2Oa < Sinatra::Base

  set :haml,      layout: :layout
  set :markdown,  layout: :layout, layout_engine: :haml

  get '/' do
    markdown :index
  end

  get '/resolve' do
    if params.has_key?("doi")
      Doi.resolve(params["doi"]) || "unavailable"
    else
      redirect to('/')
    end
  end

  run! if app_file == $0

end
