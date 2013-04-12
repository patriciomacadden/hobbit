module Bonsai
  class Base
    class << self
      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method(verb.downcase) { |path, &block| routes[verb] << compile_route!(path, &block) }
      end

      def app
        @app ||= Rack::Builder.new
      end

      alias :new! :new
      def new(*args, &block)
        instance = new!(*args, &block)
        app.run instance
        app
      end

      def routes
        @routes ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def use(middleware, *args, &block)
        app.use(middleware, *args, &block)
      end

      private

      def compile_route!(path, &block)
        route = { block: block, compiled_path: nil, extra_params: [], path: path }

        postfix = '/' if path =~ /\/\z/
        segments = path.split('/')
        segments.map! do |s|
          s.gsub!(/:\w+/) do |e|
            route[:extra_params] << e.gsub(':', '').to_sym
            '(\w+)'
          end
          s
        end
        route[:compiled_path] = /\A#{segments.join('/')}#{postfix}\z/

        route
      end
    end

    attr_reader :env, :request, :response

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env
      @request = Rack::Request.new(@env)
      @response = Rack::Response.new
      route_eval
      @response.finish
    end

    private

    def route_eval
      catch(:halt) do
        self.class.routes[@request.request_method].each do |route|
          if !!(route[:compiled_path] =~ @request.path_info)
            if route[:extra_params].any?
              matches = route[:compiled_path].match(@request.path_info)
              route[:extra_params].each_index { |i| @request.params[route[:extra_params][i]] = matches.captures[i] }
            end
            @response.write instance_eval(&route[:block])
            throw :halt
          end
        end
        @response.status = 404
      end
    end
  end
end