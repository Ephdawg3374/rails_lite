require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'

require_relative '../flash'

class ControllerBase
  attr_reader :req, :res, :route_params, :flash

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res

    @params = Params.new(req, route_params)

    @flash = Flash.new(req, res)
  end

  def flash
    @flash
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    res["Location"] = url
    res.status=302

    prevent_double_render

    session.store_session(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    res.body = content
    res.content_type = content_type

    prevent_double_render

    session.store_session(res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    converted_class_name = self.class.to_s.gsub("Controller","").underscore.pluralize

    template_path = "./app/views/#{converted_class_name}/#{template_name}.html.erb"

    contents = File.read(template_path)

    template = ERB.new(contents)

    render_content(template.result(binding), "text/html")
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end

  private

  def prevent_double_render
    if already_built_response?
      raise "don't double render bro!"
    else
      @already_built_response = res
    end
  end
end
