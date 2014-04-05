require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res

    @already_built_response = false

    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "error" if already_built_response?

    @res.body = content
    @res.content_type = type

    @already_built_response = true
    nil
  end

  # helper method to alias @already_built_response
  def already_built_response?
    #raise "Error" if @already_built_response == true
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "error" if already_built_response?

    res.status = 302
    res.header["location"] = url
    #res.setup_header(url) # res.header = url
    @already_built_response = true

  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raise "error" if already_built_response?
    controller_name = "#{self.class}".underscore
    file = File.read("views/#{controller_name}/#{template_name}.html.erb")
    content = ERB.new(file).result(binding)

    render_content(content, "text/html")
    @already_built_response = true

    # template_fname=
    #   File.join("views", self.class.name.underscore, "#{template_name}.html.erb")
    # render_content(
    #   ERB.new(File.read(template_fname)).result(binding),
    #   "text/html"
    # )
  end

  # method exposing a `Session` object
  def session
    @session || Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?

    nil
  end
end
