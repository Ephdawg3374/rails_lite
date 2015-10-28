require 'webrick'
require 'byebug'

require_relative "../config/controller_base/require_base_controller"
require_relative "../config/model_base/sql_object"

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

class HumansController < ControllerBase
  def index
    @me = Human.new(fname: "Ephraim", lname: "Pei")

    flash[:failure] = "FAILURE"

    render(:index)
  end
end

class Human < SQLObject
end

router = Router.new

# create routes
router.draw do
  get Regexp.new("/humans/"), HumansController, :index
end

server = WEBrick::HTTPServer.new(:Port => 3000)

server.mount_proc("/") do |req, res|
  route = router.run(req, res)
end

trap('INT') do
  server.shutdown
end

server.start
