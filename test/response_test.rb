require 'helper'

scope Hobbit::Response do
  scope '#initialize' do
    def default_headers
      { 'Content-Type' => 'text/html; charset=utf-8' }
    end

    test 'sets the body, status and headers with no arguments given' do
      response = Hobbit::Response.new
      assert response.status == 200
      assert response.headers == default_headers
      assert response.body == []
    end

    test 'sets the body, status and headers with arguments given' do
      status, headers, body = 200, { 'Content-Type' => 'application/json' }, ['{"name": "Hobbit"}']
      response = Hobbit::Response.new body, status, headers
      assert response.status == status
      assert response.headers == headers
      assert response.body == body
    end

    test 'sets the body if the body is a string' do
      response = Hobbit::Response.new 'hello world'
      assert response.status == 200
      assert response.headers == default_headers
      assert response.body == ['hello world']
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
      assert response['Content-Type'] == 'text/html; charset=utf-8'
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
      assert response['Content-Type'] == content_type
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
      assert response.finish == [status, headers, body]
    end

    test 'calculates the Content-Length of the body' do
      response = Hobbit::Response.new body, status, headers
      s, h, b = response.finish
      assert h.include? 'Content-Length'
      assert h['Content-Length'] == '18'
    end

    test 'calculates the Content-Length of the body, even if the body is empty' do
      response = Hobbit::Response.new
      s, h, b = response.finish
      assert h.include? 'Content-Length'
      assert h['Content-Length'] == '0'
    end
  end

  scope '#redirect' do
    def response
      @response ||= Hobbit::Response.new
    end

    test 'sets the Location header and the status code' do
      response.redirect '/hello'
      assert response.headers['Location'] == '/hello'
      assert response.status == 302
    end

    test 'sets the Location header and the status code if given' do
      response.redirect '/hello', 301
      assert response.headers['Location'] == '/hello'
      assert response.status == 301
    end
  end

  scope '#write' do
    def response
      @response ||= Hobbit::Response.new
    end

    test 'appends the argument to the body of the response' do
      response.write 'hello world'
      assert response.body == ['hello world']
    end
  end
end
