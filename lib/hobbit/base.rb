module Hobbit
  class Base
    class << self
      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method(verb.downcase) { |path = '', &block| routes[verb] << compile_route!(path, &block) }
      end

      def map(path, &block)
        stack.map(path, &block)
      end

      alias :new! :new
      def new(*args, &block)
        stack.run new!(*args, &block)
        stack
      end

      def routes
        @routes ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def settings
        @settings ||= { request_class: Rack::Request, response_class: Hobbit::Response }
      end

      def stack
        @stack ||= Rack::Builder.new
      end

      def use(middleware, *args, &block)
        stack.use(middleware, *args, &block)
      end

      private

      def compile_route!(path, &block)
        route = { block: block, compiled_path: nil, extra_params: [], path: path }

        compiled_path = path.gsub(/:\w+/) do |match|
          route[:extra_params] << match.gsub(':', '').to_sym
          '([^/?#]+)'
        end
        route[:compiled_path] = /^#{compiled_path}$/

        route
      end
    end

    attr_reader :env, :request, :response

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env
      @request = self.class.settings[:request_class].new(@env)
      @response = self.class.settings[:response_class].new
      route_eval
      @response.finish
    end

    private

    def route_eval
      catch(:halt) do
        self.class.routes[@request.request_method].each do |route|
          if route[:compiled_path] =~ @request.path_info
            route[:compiled_path].match(@request.path_info).captures.each_with_index do |value, index|
              param = route[:extra_params][index]
              @request.params[param] = value
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