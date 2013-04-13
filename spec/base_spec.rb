require 'minitest_helper'

describe Banzai::Base do
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

  describe '::app' do
    it 'must return an instance of Rack::Builder' do
      TestBaseApp.app.must_be_kind_of Rack::Builder
    end
  end

  describe '::new' do
    it 'should return an instance of Rack::Builder' do
      TestBaseApp.new.must_be_kind_of Rack::Builder
    end
  end

  describe '::routes' do
    it 'must return a Hash' do
      TestBaseApp.routes.must_be_kind_of Hash
    end
  end

  describe '::use' do
    it 'must add a middleware to the app stack' do
      skip '::use'
    end
  end

  describe '#call' do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      str = <<EOS
    describe 'when the request matches a route' do
      it 'must match #{verb} /' do
        #{verb.downcase} '/'
        last_response.must_be :ok?
        last_response.body.must_equal '#{verb}'
      end

      it 'must match #{verb} /route.json' do
        #{verb.downcase} '/route.json'
        last_response.must_be :ok?
        last_response.body.must_equal '#{verb} /route.json'
      end

      it 'must match #{verb} /route/:id.json' do
        #{verb.downcase} '/route/1.json'
        last_response.must_be :ok?
        last_response.body.must_equal '1'
      end

      it 'must match #{verb} /:name' do
        #{verb.downcase} '/banzai'
        last_response.must_be :ok?
        last_response.body.must_equal 'banzai'

        #{verb.downcase} '/hello-banzai'
        last_response.must_be :ok?
        last_response.body.must_equal 'hello-banzai'
      end
    end

    describe 'when the request not matches a route' do
      it 'must respond with 404 status code' do
        #{verb.downcase} '/not/found'
        last_response.must_be :not_found?
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