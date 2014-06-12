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
    scope "::#{verb.downcase}" do
      test 'adds a route to @routes' do
        route = app.to_app.class.routes[verb].first
        assert_equal '/', route[:path]
      end

      test 'extracts the extra_params' do
        route = app.to_app.class.routes[verb].last
        assert_equal [:name], route[:extra_params]
      end
    end
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
      assert_equal 'from map', last_response.body
    end
  end

  scope '::new' do
    test 'returns an instance of Rack::Builder' do
      assert_kind_of Rack::Builder, app
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
      assert_equal ['hello world'], body
    end
  end

  scope '::routes' do
    test 'returns a Hash' do
      assert_kind_of Hash, app.to_app.class.routes
    end
  end

  scope '::stack' do
    test 'returns an instance of Rack::Builder' do
      assert_kind_of Rack::Builder, app.to_app.class.stack
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
      assert_equal 'from use', last_response.body
    end
  end

  scope '::compile_route' do
    def block
      Proc.new { |env| [200, {}, []] }
    end

    test 'compiles /' do
      path = '/'
      route = Hobbit::Base.send :compile_route, path, &block
      assert_equal block.call({}), route[:block].call({})
      assert_equal /^\/$/.to_s, route[:compiled_path].to_s
      assert_equal [], route[:extra_params]
      assert_equal path, route[:path]
    end

    test 'compiles with .' do
      path = '/route.json'
      route = Hobbit::Base.send :compile_route, path, &block
      assert_equal block.call({}), route[:block].call({})
      assert_equal /^\/route.json$/.to_s, route[:compiled_path].to_s
      assert_equal [], route[:extra_params]
      assert_equal path, route[:path]
    end

    test 'compiles with -' do
      path = '/hello-world'
      route = Hobbit::Base.send :compile_route, path, &block
      assert_equal block.call({}), route[:block].call({})
      assert_equal /^\/hello-world$/.to_s, route[:compiled_path].to_s
      assert_equal [], route[:extra_params]
      assert_equal path, route[:path]
    end

    test 'compiles with params' do
      path = '/hello/:name'
      route = Hobbit::Base.send :compile_route, path, &block
      assert_equal block.call({}), route[:block].call({})
      assert_equal /^\/hello\/([^\/?#]+)$/.to_s, route[:compiled_path].to_s
      assert_equal [:name], route[:extra_params]
      assert_equal path, route[:path]

      path = '/say/:something/to/:someone'
      route = Hobbit::Base.send :compile_route, path, &block
      assert_equal block.call({}), route[:block].call({})
      assert_equal /^\/say\/([^\/?#]+)\/to\/([^\/?#]+)$/.to_s, route[:compiled_path].to_s
      assert_equal [:something, :someone], route[:extra_params]
      assert_equal path, route[:path]
    end

    test 'compiles with . and params' do
      path = '/route/:id.json'
      route = Hobbit::Base.send :compile_route, path, &block
      assert_equal block.call({}), route[:block].call({})
      assert_equal /^\/route\/([^\/?#]+).json$/.to_s, route[:compiled_path].to_s
      assert_equal [:id], route[:extra_params]
      assert_equal path, route[:path]
    end
  end

  scope '#call' do
    %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
      scope 'when the request matches a route' do
        test "matches #{verb} ''" do
          send verb.downcase, ''
          assert last_response.ok?
          assert_equal verb, last_response.body
        end

        test 'matches #{verb} /' do
          send verb.downcase, '/'
          assert last_response.ok?
          assert_equal verb, last_response.body
        end

        test 'matches #{verb} /route.json' do
          send verb.downcase, '/route.json'
          assert last_response.ok?
          assert_equal "#{verb} /route.json", last_response.body
        end

        test 'matches #{verb} /route/:id.json' do
          send verb.downcase, '/route/1.json'
          assert last_response.ok?
          assert_equal '1', last_response.body
        end

        test 'matches #{verb} /:name' do
          send verb.downcase, '/hobbit'
          assert last_response.ok?
          assert_equal 'hobbit', last_response.body

          send verb.downcase, '/hello-hobbit'
          assert last_response.ok?
          assert_equal 'hello-hobbit', last_response.body
        end
      end

      scope 'when the request not matches a route' do
        test 'responds with 404 status code' do
          send verb.downcase, '/not/found'
          assert last_response.not_found?
          assert_equal '', last_response.body
        end
      end
    end
  end

  scope '#halt' do
    setup do
      mock_app do
        get '/halt' do
          response.status = 501
          halt response.finish
        end

        get '/halt_finished' do
          halt [404, {}, ['Not found']]
        end
      end
    end

    test 'halts the execution with a response' do
      get '/halt'
      assert_status 501
    end

    test 'halts the execution with a finished response' do
      get '/halt_finished'
      assert_status 404
    end
  end

  test 'responds to call' do
    assert app.to_app.respond_to? :call
  end
end
