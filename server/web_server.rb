class WebServer < Sinatra::Base
  set :traps, false
  set :show_exceptions, false

  not_found do
    halt 404
  end

  error do
    halt 500
  end

  get '/ping' do
    halt 200, 'OK'
  end
end
