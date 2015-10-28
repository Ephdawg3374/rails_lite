class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name, :route_params

  def initialize(pattern, http_method, controller_class, action_name)
    @http_method = http_method
    @pattern = pattern
    @controller_class = controller_class
    @action_name = action_name
    @route_params = {}
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    (req.path =~ pattern) && (req.request_method == http_method.to_s.upcase)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    # ex: /users/1 => {:id => 1}
    matched_params = pattern.match(req.path)

    matched_params.names.each_with_index do |name, idx|
      route_params[name] = matched_params.captures[idx]
    end

    controller = controller_class.new(req, res, route_params)

    controller.invoke_action(action_name)
  end
end
