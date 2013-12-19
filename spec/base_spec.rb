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
      route[:path].must_equal '/'
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

  describe '::compile_route' do
    let(:block) { block = Proc.new { |env| [200, {}, []] } }

    it 'must compile /' do
      path = '/'
      route = Hobbit::Base.send :compile_route, path, &block
      route[:block].call({}).must_equal block.call({})
      route[:compiled_path].to_s.must_equal /^\/$/.to_s
      route[:extra_params].must_equal []
      route[:path].must_equal path
    end

    it 'must compile with .' do
      path = '/route.json'
      route = Hobbit::Base.send :compile_route, path, &block
      route[:block].call({}).must_equal block.call({})
      route[:compiled_path].to_s.must_equal /^\/route.json$/.to_s
      route[:extra_params].must_equal []
      route[:path].must_equal path
    end

    it 'must compile with -' do
      path = '/hello-world'
      route = Hobbit::Base.send :compile_route, path, &block
      route[:block].call({}).must_equal block.call({})
      route[:compiled_path].to_s.must_equal /^\/hello-world$/.to_s
      route[:extra_params].must_equal []
      route[:path].must_equal path
    end

    it 'must compile with params' do
      path = '/hello/:name'
      route = Hobbit::Base.send :compile_route, path, &block
      route[:block].call({}).must_equal block.call({})
      route[:compiled_path].to_s.must_equal /^\/hello\/([^\/?#]+)$/.to_s
      route[:extra_params].must_equal [:name]
      route[:path].must_equal path

      path = '/say/:something/to/:someone'
      route = Hobbit::Base.send :compile_route, path, &block
      route[:block].call({}).must_equal block.call({})
      route[:compiled_path].to_s.must_equal /^\/say\/([^\/?#]+)\/to\/([^\/?#]+)$/.to_s
      route[:extra_params].must_equal [:something, :someone]
      route[:path].must_equal path
    end

    it 'must compile with . and params' do
      path = '/route/:id.json'
      route = Hobbit::Base.send :compile_route, path, &block
      route[:block].call({}).must_equal block.call({})
      route[:compiled_path].to_s.must_equal /^\/route\/([^\/?#]+).json$/.to_s
      route[:extra_params].must_equal [:id]
      route[:path].must_equal path
    end
  end

  describe '#call' do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      str = <<EOS
    describe 'when the request matches a route' do
      it 'must match #{verb} ""' do
        #{verb.downcase} ''
        last_response.must_be :ok?
        last_response.body.must_equal '#{verb}'
      end

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

  describe '::halt' do
    before do
      mock_app do
        get('/halt') do
          halt 501
          response.write 'Hello world'
        end

        get('/halt_string') do
          halt 501, body: 'Halt!'
        end

        get('/halt_array') do
          halt 501, body: ['Halt!']
        end

        get('/halt_hash') do
          halt 501, body: { message: 'Halt!' }
        end

        get('/halt_headers') do
          halt 501, headers: { header: 'OK' }
        end
      end
    end

    it 'return the response given to halt function' do
      get '/halt'
      last_response.headers.must_equal({"Content-Length" => nil})
      last_response.body.must_equal ''
      last_response.status.must_equal 501
    end

    it 'accepts a string as body' do
      get '/halt_string'
      last_response.body.must_equal 'Halt!'
      last_response.status.must_equal 501
    end

    it 'accepts an Array as body' do
      get '/halt_array'
      last_response.body.must_equal 'Halt!'
      last_response.status.must_equal 501
    end

    it 'accepts a Hash as body' do
      get '/halt_hash'
      last_response.body.must_equal '[:message, "Halt!"]'
      last_response.status.must_equal 501
    end

    it 'accepts headers' do
      get '/halt_headers'
      last_response.headers.must_equal({:header=>"OK", "Content-Length"=>nil})
      last_response.status.must_equal 501
    end

  end

  it 'must respond to call' do
    app.to_app.must_respond_to :call
  end
end
