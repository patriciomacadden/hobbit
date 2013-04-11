class TestRenderApp < Bonsai::Base
  include Bonsai::Render

  def name
    'Bonsai'
  end

  get('/') { render File.expand_path('../views/index.erb', __FILE__) }
  get('/using-context') { render File.expand_path('../views/hello.erb', __FILE__) }
end
