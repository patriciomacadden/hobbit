class App < Banzai::Base
  get '/' do
    'Hello Banzai!'
  end

  get '/hi' do
    response.redirect '/'
  end
end