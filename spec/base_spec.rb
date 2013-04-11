require 'minitest_helper'

describe Bonsai::Base do
  include Rack::Test::Methods

  def app
    TestBaseApp.new
  end

  %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
    str = <<EOS
  describe "::#{verb.downcase}" do
    it 'must add a route to @routes' do
      #route = TestBaseApp.routes['#{verb}'].first
      #route[:path].must_equal '/'
    end

    it 'must extract the extra_params' do
      route = TestBaseApp.routes['#{verb}'].last
      route[:extra_params].must_equal [:name]
    end
  end
EOS
    class_eval str
  end

  describe '::routes' do
    it 'must return a Hash' do
      TestBaseApp.routes.must_be_kind_of Hash
    end
  end

  describe '#call' do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      str = <<EOS
    describe 'when the request matches a route' do
      it 'must #{verb} /' do
        #{verb.downcase} '/'
        last_response.must_be :ok?
        last_response.body.must_equal '#{verb}'
      end

      it 'must #{verb} /:name' do
        #{verb.downcase} '/bonsai'
        last_response.must_be :ok?
        last_response.body.must_equal 'bonsai'
      end
    end

    describe 'when the request not matches a route' do
      it 'must respond with 404 status code' do
        #{verb.downcase} '/not/found'
        last_response.must_be :not_found?
        last_response.body.must_equal ''
      end
    end

    describe 'when the block raises an exception' do
      it 'must respond with 500 status code' do
        #{verb.downcase} '/raise'
        last_response.must_be :server_error?
        last_response.body.must_equal ''
      end
    end
EOS
      class_eval str
    end
  end

  it 'must respond to call' do
    app = TestBaseApp.new
    app.must_respond_to :call
  end
end
