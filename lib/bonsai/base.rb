module Bonsai
  class Base
    class << self
      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method(verb.downcase) { |path, &block| routes[verb] << compile_route!(path, &block) }
      end

      def routes
        @routes ||= Hash.new { |hash, key| hash[key] = [] }
      end

      private

      def compile_route!(path, &block)
        route = { block: block, compiled_path: nil, extra_params: [], path: path }

        postfix = '/' if path =~ /\/\z/
        segments = path.split('/')
        segments.map! do |s|
          if s =~ /:\w+/
            route[:extra_params] << s.gsub(':', '').to_sym
            s.gsub!(/:\w+/, '(\w+)')
          else
            s
          end
        end
        route[:compiled_path] = /\A#{segments.join('/')}#{postfix}\z/

        route
      end
    end

    attr_reader :builder, :env, :request, :response

    def initialize
      @builder = Rack::Builder.new
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env
      @request = Rack::Request.new(@env)
      @response = Rack::Response.new

      begin
        route = catch(:halt) do
          self.class.routes[@request.request_method].each do |r|
            throw(:halt, r) if !!(r[:compiled_path] =~ @request.path_info)
          end
          raise NotFound
        end

        if route[:extra_params].any?
          matches = route[:compiled_path].match(@request.path_info)
          route[:extra_params].each_index { |i| @request.params[route[:extra_params][i]] = matches.captures[i] }
        end

        @response.status = 200
        @response.body = [instance_eval(&route[:block])]
      rescue NotFound
        @response.status = 404
      rescue Exception
        @response.status = 500
      end

      @response.finish
    end

    def use(middleware, *args, &block)
      builder.use(middleware, *args, &block)
    end
  end
end
