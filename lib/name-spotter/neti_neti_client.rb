class NameSpotter
  class NetiNetiClient < Client
    def initialize(opts = { host: '0.0.0.0', port: 6384 })
      super 
    end

    def find(text)
      # the form does not get sent if text is nil or empty
      return [] if text.nil? || text.empty?
      response = RestClient.post("http://#{@host}:#{@port}", data: text, timeout: 600, connection: "Keep-Alive"})
      response.body.split("|").collect do |info|
        res = info.split(",")
        name = res[0...-2].join(",")
        offset_start = res[-2]
        name.force_encoding('utf-8')
        normalized_name = NameSpotter::ScientificName.normalize(name)
        NameSpotter::ScientificName.new(name, :scientific_name => normalized_name, :start_position => offset_start.to_i)
      end
    end
  end
end
