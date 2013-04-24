require 'minitest_helper'

describe Hobbit::Render do
  include Hobbit::Mock
  include Rack::Test::Methods

  def app
    mock_app do
      include Hobbit::Render

      def name
        'Hobbit'
      end

      get('/') { render File.expand_path('../fixtures/views/index.erb', __FILE__) }
      get('/using-context') { render File.expand_path('../fixtures/views/hello.erb', __FILE__) }
    end
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
      last_response.body.must_match /Hello Hobbit!/
    end
  end
end