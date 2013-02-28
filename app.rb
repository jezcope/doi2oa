require 'sinatra'

require 'haml'
require 'redcarpet'

class Doi2Oa < Sinatra::Base

  set :haml,      layout: :layout
  set :markdown,  layout: :layout, layout_engine: :haml

  get '/' do
    markdown :index
  end

  run! if app_file == $0

end
