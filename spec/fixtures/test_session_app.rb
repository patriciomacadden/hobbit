require 'securerandom'

class TestSessionApp < Hobbit::Base
  include Hobbit::Session
  use Rack::Session::Cookie, secret: SecureRandom.hex(64)

  get '/' do
    session[:name] = 'hobbit'
  end

  get '/name' do
    session[:name]
  end
end