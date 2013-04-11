class TestBaseApp < Bonsai::Base
  %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
    class_eval "#{verb.downcase}('/') { '#{verb}' }"
    class_eval "#{verb.downcase}('/raise') { raise Exception, 'Oops' }"
    class_eval "#{verb.downcase}('/:name') { request.params[:name] }"
  end
end
