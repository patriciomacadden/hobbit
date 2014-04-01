require 'forwardable'

module Hobbit
  class Base
    class << self
      extend Forwardable

      def_delegators :stack, :map, :use

      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method(verb.downcase) { |path, &block| routes[verb] << compile_route(path, &block) }
      end

      alias :_new :new
      def new(*args, &block)
        stack.run _new(*args, &block)
        stack
      end

      def call(env)
        new.call env
      end

      def routes
        @routes ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def stack
        @stack ||= Rack::Builder.new
      end

      private

      def compile_route(path, &block)
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
      dup._call env
    end

    def _call(env)
      @env = env
      @request = Hobbit::Request.new @env
      @response = Hobbit::Response.new
      catch(:halt) { route_eval }
      @response.finish
    end

    def halt(*res)
      response.status = res.detect { |s| s.is_a? Fixnum } || 200
      response.headers.merge! res.detect { |h| h.is_a? Hash } || {}
      response.write res.detect { |b| b.is_a? String } || ''

      throw :halt, response
    end

    private

    def route_eval
      route = find_route

      if route
        response.write instance_eval(&route[:block])
      else
        halt 404
      end
    end

    def find_route
      route = self.class.routes[request.request_method].detect do |r|
        r[:compiled_path] =~ request.path_info
      end

      if route
        $~.captures.each_with_index do |value, index|
          param = route[:extra_params][index]
          request.params[param] = value
        end
      end

      route
    end
  end
end
