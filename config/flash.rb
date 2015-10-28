require 'json'

class Flash
  attr_reader :messages

  def initialize(req, res)
    @cookie = req.cookies.find { |c| c.name == "_rails_lite_app_flash" }

    if @cookie
      flash = JSON.parse(@cookie.value)
      @messages = flash["messages"]
      req.cookies.delete(@cookie)
    else
      @messages = Hash.new { [] }
      create_new_cookie(res)
    end

  end

  def [](key)
    messages[key]
  end

  def []=(key, val)
    messages[key] = val
  end

  def now
    delete_cookie
    self
  end

  def each(&prc) #prc = { |err_msg, err_type| ... }
    messages.each do |err_type, err_msg|
      prc.call(err_type, err_msg)
    end
  end

  private

  def create_new_cookie(res)
    @cookie = WEBrick::Cookie.new("_rails_lite_app", self.to_json)
    res.cookies << @cookie
  end

  def delete_cookie
    res.cookies.delete(@cookie)
    @cookie = nil
  end

end
