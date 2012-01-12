class NameSpotter
  class NetiNetiClient < Client
    def initialize(opts = { host: '0.0.0.0', port: 6384 })
      super 
    end

    def find(text)
      # the form does not get sent if text is nil or empty
      return [] if text.nil? || text.empty?
      response = RestClient.post("http://#{@host}:#{@port}", data: text)

      response.body.split("|").collect do |info|
        name, offset_start = info.split(',')
        normalized_name = NameSpotter::ScientificName.normalize(name)
        NameSpotter::ScientificName.new(name, :scientific_name => normalized_name, :start_position => offset_start.to_i)
      end
    end
  end
end
