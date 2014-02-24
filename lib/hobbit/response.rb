require 'forwardable'

module Hobbit
  class Response
    attr_accessor :status
    attr_reader :headers, :body
    extend Forwardable
    def_delegators :headers, :[], :[]=

    def initialize(body = [], status = 200, headers = { 'Content-Type' => 'text/html; charset=utf-8' })
      @body, @headers, @status = [], headers, status
      @length = 0

      if body.respond_to? :to_str
        write body.to_str
      elsif body.respond_to? :each
        body.each { |i| write i.to_s }
      else
        raise TypeError, 'body must #respond_to? #to_str or #each'
      end
    end

    def finish
      headers['Content-Length'] = @length.to_s
      [status, headers, body]
    end

    def redirect(target, status = 302)
      self.status = status
      headers['Location'] = target
    end

    def write(string)
      s = string.to_s
      @length += s.bytesize

      body << s
    end
  end
end
