require 'helper'

scope Hobbit::Request do
  scope '#initialize' do
    test "sets the path info to / if it's empty" do
      env = { 'PATH_INFO' => '', 'REQUEST_METHOD' => 'GET' }
      request = Hobbit::Request.new env
      assert_equal '/', request.path_info
    end

    test "doesn't change the path info if it's not empty" do
      env = { 'PATH_INFO' => '/hello_world', 'REQUEST_METHOD' => 'GET' }
      request = Hobbit::Request.new env
      assert_equal '/hello_world', request.path_info
    end
  end
end
