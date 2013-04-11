class App < Bonsai::Base
  get '/' do
    'Hello Bonsai!'
  end

  get '/hi' do
    response.redirect '/'
  end
end
