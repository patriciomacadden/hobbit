require 'minitest_helper'

describe Hobbit::Session do
  include Hobbit::Mock
  include Rack::Test::Methods

  def app
    mock_app do
      include Hobbit::Session
      use Rack::Session::Cookie, secret: SecureRandom.hex(64)

      get '/' do
        session[:name] = 'hobbit'
      end

      get '/name' do
        session[:name]
      end
    end
  end

  describe '#session' do
    it 'must return a session object' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_equal 'hobbit'

      get '/name'
      last_response.must_be :ok?
      last_response.body.must_equal 'hobbit'
    end
  end
end