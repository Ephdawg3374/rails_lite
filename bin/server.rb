require 'webrick'
require_relative '../lib/phase6/controller_base'
require_relative '../lib/phase6/router'
require_relative '../lib/bonus/flash'

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

class UsersController < Phase6::ControllerBase
  def index
    render(:new)
  end
end

router = Phase6::Router.new

# create routes
router.draw do
  get Regexp.new("/users/"), UsersController, :index
end

p router.routes

server = WEBrick::HTTPServer.new(:Port => 3000)

server.mount_proc("/") do |req, res|
  p req.path
  route = router.run(req, res)
end

trap('INT') do
  server.shutdown
end

server.start
