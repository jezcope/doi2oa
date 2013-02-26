require 'sinatra'

class Doi2Oa < Sinatra::Base

  get '/' do
    "Hello there, my little #OpenAccess world!"
  end

  run! if app_file == $0

end
