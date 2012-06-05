require "ostruct"
require "rest_client"
require "uri"
require "json"
require "nokogiri"
require "socket"
require "unicode_utils"
require File.join(File.dirname(__FILE__), 'name-spotter', 'client')

Dir["#{File.dirname(__FILE__)}/name-spotter/**/*.rb"].each {|f| require f}

class NameSpotter

  def initialize(client)
    @client = client
  end

  def find(input, format = nil)
    text = to_text(input)
    names = @client.find(text)
    names = names.map{ |n| n.to_hash }
    return { names: names } unless format
    format == "json" ? to_json(names) : to_xml(names)
  end
  
  private

  def to_text(input)
    input
  end
  
  def to_json(names)
    return JSON.fast_generate({ names: names })
  end
  
  def to_xml(names)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.names do
        names.each do |name|
          xml.verbatim       name[:verbatim]
          xml.scientificName name[:scientificName]
          xml.offsetStart    name[:offsetStart]
          xml.offsetEnd      name[:offsetEnd]
        end 
      end
    end
    builder.to_xml
  end

end

