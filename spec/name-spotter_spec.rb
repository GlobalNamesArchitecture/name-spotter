require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NameSpotter" do
  before(:all) do
    neti_neti = NameSpotter::NetiNetiClient.new()
    taxon_finder = NameSpotter::TaxonFinderClient.new()
    @neti = NameSpotter.new(neti_neti)
    @tf = NameSpotter.new(taxon_finder)
    @clients = [@neti, @tf]
  end

  it "should exist" do
    @neti.is_a?(NameSpotter).should be_true
    @tf.is_a?(NameSpotter).should be_true
  end

  it "should use ruby as default format" do
    @clients.each do |c|
      c.find(nil).should == {names: []}
    end
  end

  it "should return empty result if input is empty" do
    @clients.each do |c|
      c.find(nil, 'json').should == "{\"names\":[]}"
      c.find(nil, "xml").should == "<?xml version=\"1.0\"?>\n<names/>\n"
      c.find('', 'json').should == "{\"names\":[]}"
      c.find('', "xml").should == "<?xml version=\"1.0\"?>\n<names/>\n"
    end
  end
  
  it "should return empty result if no names are found" do
    text = "one two three, no scientific names"
    @clients.each do |c|
      c.find(text, "json").should == "{\"names\":[]}"
      c.find(text, "xml").should == "<?xml version=\"1.0\"?>\n<names/>\n"
    end
  end

  it "should be able to find scientific names in text" do
    text = "Some text that has Betula\n alba and Mus musculus and \neven B. alba and even M. mus-\nculus. Also it has name unknown before: Varanus bitatawa species"
    res = @neti.find(text)[:names].map { |n| n[:scientificName] } 
    res.should == ["Betula alba", "Mus musculus", "B. alba", "Varanus bitatawa"]
    res = @tf.find(text)[:names].map { |n| n[:scientificName] } 
    res.should == ["Betula alba", "Mus musculus", "B[etula] alba", "Varanus"]
  end

end
