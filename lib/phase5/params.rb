require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      #print "#{req.query_string}\n"
      @params = Hash.new

      if req.query_string
        @params.merge!(parse_www_encoded_form(req.query_string))
      elsif req.body
        @params.merge!(parse_www_encoded_form(req.body))
      end
      @params.merge!(route_params)
    end

    def [](key)
      #debugger
      @params[key.to_s] || @params[key.to_sym]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)

      hash = {}

      parsed_arr = URI::decode_www_form(www_encoded_form)
      #[["user[address][street]", "main"], ["user[address][zip]", "89436"]]
      #debugger
      parsed_arr.each do |keys, value|
        tmp = hash

        parsed_keys = parse_key(keys)
        #["user", "address", "street"]

        parsed_keys.each_with_index do |key, idx|
          # debugger
          if idx == parsed_keys.length - 1
            tmp[key] = value
          else
            tmp[key] = {} if tmp[key].nil?

            tmp = tmp[key]
          end
        end
      end
      hash
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
