class TestRenderApp < Hobbit::Base
  include Hobbit::Render

  def name
    'Hobbit'
  end

  get('/') { render File.expand_path('../views/index.erb', __FILE__) }
  get('/using-context') { render File.expand_path('../views/hello.erb', __FILE__) }
end