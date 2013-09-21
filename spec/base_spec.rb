require 'minitest_helper'

describe Hobbit::Base do
  include Hobbit::Mock
  include Rack::Test::Methods

  def app
    @app
  end

  before do
    mock_app do
      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        class_eval "#{verb.downcase} { '#{verb}' }"
        class_eval "#{verb.downcase}('/') { '#{verb}' }"
        class_eval "#{verb.downcase}('/route.json') { '#{verb} /route.json' }"
        class_eval "#{verb.downcase}('/route/:id.json') { request.params[:id] }"
        class_eval "#{verb.downcase}('/:name') { request.params[:name] }"
      end
    end
  end

  %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
    str = <<EOS
  describe "::#{verb.downcase}" do
    it 'must add a route to @routes' do
      route = app.to_app.class.routes['#{verb}'].first
      route[:path].must_equal ''
    end

    it 'must extract the extra_params' do
      route = app.to_app.class.routes['#{verb}'].last
      route[:extra_params].must_equal [:name]
    end
  end
EOS
    class_eval str
  end

  describe '::map' do
    before do
      mock_app do
        map '/map' do
          run Proc.new { |env| [200, {}, ['from map']] }
        end

        get('/') { 'hello world' }
      end
    end

    it 'must mount a application to the rack stack' do
      get '/map'
      last_response.body.must_equal 'from map'
    end
  end

  describe '::new' do
    it 'should return an instance of Rack::Builder' do
      app.must_be_kind_of Rack::Builder
    end
  end

  describe '::routes' do
    it 'must return a Hash' do
      app.to_app.class.routes.must_be_kind_of Hash
    end
  end

  describe '::stack' do
    it 'must return an instance of Rack::Builder' do
      app.to_app.class.stack.must_be_kind_of Rack::Builder
    end
  end

  describe '::use' do
    before do
      mock_app do
        middleware = Class.new do
          def initialize(app = nil)
            @app = app
          end

          def call(env)
            request = Rack::Request.new(env)
            @app.call(env) unless request.path_info == '/use'
            [200, {}, 'from use']
          end
        end

        use middleware

        get('/') { 'hello world' }
      end
    end

    it 'must add a middleware to the rack stack' do
      get '/use'
      last_response.body.must_equal 'from use'
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
        #{verb.downcase} '/hobbit'
        last_response.must_be :ok?
        last_response.body.must_equal 'hobbit'

        #{verb.downcase} '/hello-hobbit'
        last_response.must_be :ok?
        last_response.body.must_equal 'hello-hobbit'
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
    app.to_app.must_respond_to :call
  end
end
