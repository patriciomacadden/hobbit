require 'minitest_helper'

describe Hobbit::Session do
  include Rack::Test::Methods

  def app
    TestSessionApp.new
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