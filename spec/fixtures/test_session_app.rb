require 'securerandom'

class TestSessionApp < Banzai::Base
  include Banzai::Session
  use Rack::Session::Cookie, secret: SecureRandom.hex(64)

  get '/' do
    session[:name] = 'banzai'
  end

  get '/name' do
    session[:name]
  end
end