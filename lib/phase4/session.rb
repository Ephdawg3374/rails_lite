require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      cookie = req.cookies.find { |c| c.name == "_rails_lite_app" }

      if cookie
        @session_content = JSON.parse(cookie.value)
      else
        @session_content = {}
      end
    end

    def [](key)
      @session_content[key]
    end

    def []=(key, val)
      @session_content[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      new_cookie = WEBrick::Cookie.new("_rails_lite_app", @session_content.to_json)
      res.cookies << new_cookie
    end
  end
end
