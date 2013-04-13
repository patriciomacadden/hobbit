class App < Hobbit::Base
  get '/' do
    'Hello Hobbit!'
  end

  get '/hi' do
    response.redirect '/'
  end
end