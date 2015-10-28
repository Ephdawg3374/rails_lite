require 'byebug'

module Phase6
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

  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    # simply adds a new route to the list of routes
    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    # evaluate the proc in the context of the instance
    # for syntactic sugar :)
    def draw(&proc)
      instance_eval(&proc)
    end

    # make each of these methods that
    # when called add route
    [:get, :post, :put, :delete].each do |http_method|
      define_method(http_method) do |pattern, controller_class, action_name, method=http_method|
        add_route(pattern, method, controller_class, action_name)
      end
    end

    # should return the route that matches this request
    def match(req)
      @routes.each { |route| return route if route.matches?(req) }
      nil
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      matching_route = match(req)

      if matching_route
        matching_route.run(req, res)
      else
        res.status = 404
        res.body = "Page not found! Sorry bro!!"
      end
    end
  end
end
