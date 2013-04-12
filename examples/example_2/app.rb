class App < Bonsai::Base
  include Bonsai::Render

  get '/' do
    render File.expand_path('../views/index.html.erb', __FILE__)
  end
end