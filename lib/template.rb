require 'erb'

class Template
  PATH_TO_TEMPLATES = '../config/templates'

  def self.[](template_name, locals = {})
    local_obj = build_local_object(locals)
    content = ERB.new(File.read(File.dirname(__FILE__) + '/' + PATH_TO_TEMPLATES + '/' + template_name + '.erb'))
    content.result(local_obj.get_binding)
  end

  private

  def self.build_local_object(locals)
    o = Object.new
    o.define_singleton_method('get_binding') { binding }
    locals.each do |key, value|
      o.define_singleton_method(key) { value }
    end
    o
  end
end