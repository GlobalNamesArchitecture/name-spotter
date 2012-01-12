class NameSpotter
  class Client
    class ClientError < Exception; end

    attr_reader :host
    attr_reader :port

    def initialize(opts)
      @host = opts[:host]
      @port = opts[:port]
      @names = []
    end

    def find(text)
      raise "Subclass must implement find"
    end

    def add_name(name)
      @names << name
    end
  end
end
