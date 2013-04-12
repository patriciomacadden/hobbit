require 'tilt'

module Bonsai
  module Render
    def render(template, locals = {}, options = {}, &block)
      cache.fetch(template) do
        Tilt.new(template, options)
      end.render(self, locals, &block)
    end

    private

    def cache
      Thread.current[:cache] ||= Tilt::Cache.new
    end
  end
end