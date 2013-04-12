require 'minitest_helper'

describe Bonsai::Render do
  include Rack::Test::Methods

  def app
    TestRenderApp.new
  end

  describe '#render' do
    it 'must render a template' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_match /Hello World!/
    end

    it 'must use the app as context' do
      get '/using-context'
      last_response.must_be :ok?
      last_response.body.must_match /Hello Bonsai!/
    end
  end
end