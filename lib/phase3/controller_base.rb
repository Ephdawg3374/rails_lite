require_relative '../phase2/controller_base'
require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def render(template_name)
      converted_class_name = self.class.to_s.gsub("Controller","").underscore.pluralize

      template_path = "views/#{converted_class_name}/#{template_name}.html.erb"

      contents = File.read(template_path)

      template = ERB.new(contents)

      render_content(template.result(binding), "text/html")
    end
  end
end
