require 'helper'

scope Hobbit::Response do
  scope '#initialize' do
    def default_headers
      { 'Content-Type' => 'text/html; charset=utf-8' }
    end

    test 'sets the body, status and headers with no arguments given' do
      response = Hobbit::Response.new
      assert_equal 200, response.status
      assert_equal default_headers, response.headers
      assert_equal [], response.body
    end

    test 'sets the body, status and headers with arguments given' do
      status, headers, body = 200, { 'Content-Type' => 'application/json' }, ['{"name": "Hobbit"}']
      response = Hobbit::Response.new body, status, headers
      assert_equal status, response.status
      assert_equal headers, response.headers
      assert_equal body, response.body
    end

    test 'sets the body if the body is a string' do
      response = Hobbit::Response.new 'hello world'
      assert 200, response.status
      assert default_headers, response.headers
      assert ['hello world'], response.body
    end

    test 'raises a TypeError if body does not respond to :to_str or :each' do
      assert_raises TypeError do
        Hobbit::Response.new 1
      end
    end
  end

  scope '#[]' do
    def response
      Hobbit::Response.new
    end

    test 'responds to #[]' do
      assert response.respond_to? :[]
    end

    test 'returns a header' do
      assert_equal 'text/html; charset=utf-8', response['Content-Type']
    end
  end

  scope '#[]=' do
    def response
      Hobbit::Response.new
    end

    test 'responds to #[]=' do
      assert response.respond_to? :[]=
    end

    test 'sets a header' do
      content_type = 'text/html; charset=utf-8'
      response['Content-Type'] = content_type
      assert_equal content_type, response['Content-Type']
    end
  end

  scope '#finish' do
    def status
      200
    end

    def headers
      { 'Content-Type' => 'application/json', 'Content-Length' => '18' }
    end

    def body
      ['{"name": "Hobbit"}']
    end

    test 'returns a 3 elements array with status, headers and body' do
      response = Hobbit::Response.new body, status, headers
      assert_equal [status, headers, body], response.finish
    end

    test 'calculates the Content-Length of the body' do
      response = Hobbit::Response.new body, status, headers
      s, h, b = response.finish
      assert_includes h, 'Content-Length'
      assert_equal '18', h['Content-Length']
    end

    test 'calculates the Content-Length of the body, even if the body is empty' do
      response = Hobbit::Response.new
      s, h, b = response.finish
      assert_includes h, 'Content-Length'
      assert_equal '0', h['Content-Length']
    end
  end

  scope '#redirect' do
    def response
      @response ||= Hobbit::Response.new
    end

    test 'sets the Location header and the status code' do
      response.redirect '/hello'
      assert_equal '/hello', response.headers['Location']
      assert_equal 302, response.status
    end

    test 'sets the Location header and the status code if given' do
      response.redirect '/hello', 301
      assert_equal '/hello', response.headers['Location']
      assert_equal 301, response.status
    end
  end

  scope '#write' do
    def response
      @response ||= Hobbit::Response.new
    end

    test 'appends the argument to the body of the response' do
      response.write 'hello world'
      assert_equal ['hello world'], response.body
    end
  end
end
