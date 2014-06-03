require 'helper'

scope Hobbit::Base do
  setup do
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
  scope "::#{verb.downcase}" do
    test 'adds a route to @routes' do
      route = app.to_app.class.routes['#{verb}'].first
      assert route[:path] == '/'
    end

    test 'extracts the extra_params' do
      route = app.to_app.class.routes['#{verb}'].last
      assert route[:extra_params] == [:name]
    end
  end
EOS
    instance_eval str
  end

  scope '::map' do
    setup do
      mock_app do
        map '/map' do
          run Proc.new { |env| [200, {}, ['from map']] }
        end

        get('/') { 'hello world' }
      end
    end

    test 'mounts an application to the rack stack' do
      get '/map'
      assert last_response.body == 'from map'
    end
  end

  scope '::new' do
    test 'returns an instance of Rack::Builder' do
      assert app.kind_of? Rack::Builder
    end
  end

  scope '::call' do
    test 'creates a new instance and sends the call message' do
      a = Class.new(Hobbit::Base) do
        get '/' do
          'hello world'
        end
      end

      env = { 'PATH_INFO' => '/', 'REQUEST_METHOD' => 'GET' }
      status, headers, body = a.call env
      assert body == ['hello world']
    end
  end

  scope '::routes' do
    test 'returns a Hash' do
      assert app.to_app.class.routes.kind_of? Hash
    end
  end

  scope '::stack' do
    test 'returns an instance of Rack::Builder' do
      assert app.to_app.class.stack.kind_of? Rack::Builder
    end
  end

  scope '::use' do
    setup do
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

    test 'adds a middleware to the rack stack' do
      get '/use'
      assert last_response.body == 'from use'
    end
  end

  scope '::compile_route' do
    def block
      Proc.new { |env| [200, {}, []] }
    end

    test 'compiles /' do
      path = '/'
      route = Hobbit::Base.send :compile_route, path, &block
      assert route[:block].call({}) == block.call({})
      assert route[:compiled_path].to_s == /^\/$/.to_s
      assert route[:extra_params] == []
      assert route[:path] == path
    end

    test 'compiles with .' do
      path = '/route.json'
      route = Hobbit::Base.send :compile_route, path, &block
      assert route[:block].call({}) == block.call({})
      assert route[:compiled_path].to_s == /^\/route.json$/.to_s
      assert route[:extra_params] == []
      assert route[:path] == path
    end

    test 'compiles with -' do
      path = '/hello-world'
      route = Hobbit::Base.send :compile_route, path, &block
      assert route[:block].call({}) == block.call({})
      assert route[:compiled_path].to_s == /^\/hello-world$/.to_s
      assert route[:extra_params] == []
      assert route[:path] == path
    end

    test 'compiles with params' do
      path = '/hello/:name'
      route = Hobbit::Base.send :compile_route, path, &block
      assert route[:block].call({}) == block.call({})
      assert route[:compiled_path].to_s == /^\/hello\/([^\/?#]+)$/.to_s
      assert route[:extra_params] == [:name]
      assert route[:path] == path

      path = '/say/:something/to/:someone'
      route = Hobbit::Base.send :compile_route, path, &block
      assert route[:block].call({}) == block.call({})
      assert route[:compiled_path].to_s == /^\/say\/([^\/?#]+)\/to\/([^\/?#]+)$/.to_s
      assert route[:extra_params] == [:something, :someone]
      assert route[:path] == path
    end

    test 'compiles with . and params' do
      path = '/route/:id.json'
      route = Hobbit::Base.send :compile_route, path, &block
      assert route[:block].call({}) == block.call({})
      assert route[:compiled_path].to_s == /^\/route\/([^\/?#]+).json$/.to_s
      assert route[:extra_params] == [:id]
      assert route[:path] == path
    end
  end

  scope '#call' do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      str = <<EOS
    scope 'when the request matches a route' do
      test 'matches #{verb} ""' do
        #{verb.downcase} ''
        assert last_response.ok?
        assert last_response.body == '#{verb}'
      end

      test 'matches #{verb} /' do
        #{verb.downcase} '/'
        assert last_response.ok?
        assert last_response.body == '#{verb}'
      end

      test 'matches #{verb} /route.json' do
        #{verb.downcase} '/route.json'
        assert last_response.ok?
        assert last_response.body == '#{verb} /route.json'
      end

      test 'matches #{verb} /route/:id.json' do
        #{verb.downcase} '/route/1.json'
        assert last_response.ok?
        assert last_response.body == '1'
      end

      test 'matches #{verb} /:name' do
        #{verb.downcase} '/hobbit'
        assert last_response.ok?
        assert last_response.body == 'hobbit'

        #{verb.downcase} '/hello-hobbit'
        assert last_response.ok?
        assert last_response.body == 'hello-hobbit'
      end
    end

    scope 'when the request not matches a route' do
      test 'responds with 404 status code' do
        #{verb.downcase} '/not/found'
        assert last_response.not_found?
        assert last_response.body == ''
      end
    end
EOS
      instance_eval str
    end
  end

  scope '#halt' do
    setup do
      mock_app do
        get '/halt_fixnum' do
          halt 501
          response.write 'Hello world'
        end

        get '/halt_string' do
          halt 'Halt!'
        end

        get '/halt_hash' do
          halt(header: 'OK')
        end

        get '/halt_combined' do
          halt 404, 'Not Found'
        end
      end
    end

    test 'returns the response given to halt function' do
      get '/halt_fixnum'
      assert last_response.body == ''
      assert last_response.headers == { 'Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => '0' }
      assert last_response.status == 501
    end

    test 'accepts body' do
      get '/halt_string'
      assert last_response.body == 'Halt!'
      assert last_response.headers == { 'Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => '5' }
      assert last_response.status == 200
    end

    test 'accepts headers' do
      get '/halt_hash'
      assert last_response.body == ''
      assert last_response.headers == { 'Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => '0', header: 'OK' }
      assert last_response.status == 200
    end

    test 'accepts combinations' do
      get '/halt_combined'
      assert last_response.body == 'Not Found'
      assert last_response.headers == { 'Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => '9' }
      assert last_response.status == 404
    end
  end

  test 'responds to call' do
    assert app.to_app.respond_to? :call
  end
end
