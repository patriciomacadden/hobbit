require 'minitest_helper'

describe Bonsai::Session do
  include Rack::Test::Methods

  def app
    TestSessionApp.new
  end

  describe '#session' do
    it 'must return a session object' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_equal 'bonsai'

      get '/name'
      last_response.must_be :ok?
      last_response.body.must_equal 'bonsai'
    end
  end
end