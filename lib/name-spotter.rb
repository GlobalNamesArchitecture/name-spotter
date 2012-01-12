require "ostruct"
require "rest_client"
require "uri"
require "json"
require "nokogiri"
require "socket"
require File.join(File.dirname(__FILE__), 'name-spotter', 'client')

Dir["#{File.dirname(__FILE__)}/name-spotter/**/*.rb"].each {|f| require f}

class NameSpotter

  def initialize(client)
    @client = client
  end

  def find(input, format)
    text = to_text(input)
    result = @client.find(text)
  end
  
  private

  def to_text(input)
    input
  end

end

