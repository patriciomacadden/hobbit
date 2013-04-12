require 'securerandom'

class TestSessionApp < Bonsai::Base
  include Bonsai::Session
  use Rack::Session::Cookie, secret: SecureRandom.hex(64)

  get '/' do
    session[:name] = 'bonsai'
  end

  get '/name' do
    session[:name]
  end
end