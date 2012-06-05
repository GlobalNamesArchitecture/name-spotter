# encoding: utf-8
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
    text = "Some text that has Betula\n alba and Mus musculus and \neven B. alba and even M. mus-\nculus and unicoded name Aranea röselii. Also it has name unknown before: Varanus bitatawa species"
    res = @neti.find(text)[:names].map { |n| n[:scientificName] } 
    res.should == ["Betula alba", "Mus musculus", "B. alba", "Aranea röselii", "Varanus bitatawa"]
    tf_res = @tf.find(text)
    res = tf_res[:names].map { |n| n[:scientificName] } 
    res.should == ["Betula alba", "Mus musculus", "B[etula] alba", "Aranea röselii", "Varanus"]
  end

  
  it "should not remember previous search results" do
    text = "Some text that has Betula\n alba and Mus musculus and \neven B. alba and even M. mus-\nculus. Also it has name unknown before: Varanus bitatawa species"
    res = @neti.find(text)[:names].map { |n| n[:scientificName] } 
    res.should == ["Betula alba", "Mus musculus", "B. alba", "Varanus bitatawa"]
    res = @tf.find(text)[:names].map { |n| n[:scientificName] } 
    res.should == ["Betula alba", "Mus musculus", "B[etula] alba", "Varanus"]
    text = "Some another text that has Xysticus \ncanadensis and Pardosa moesta and \neven X. canadensis and even P. mo-\nesta."
    res = @neti.find(text)[:names].map { |n| n[:scientificName] } 
    res.should == ['Xysticus canadensis', 'Pardosa moesta', 'X. canadensis']
    res = @tf.find(text)[:names].map { |n| n[:scientificName] } 
    res.should == ['Xysticus canadensis', 'Pardosa moesta', 'X[ysticus] canadensis']
  end

  it "should get back correct names using offsets in utf-8 based text" do
    text = "A text with multibyte characters नेति नेति:  Some text that has Betula\n alba and Mus musculus and \neven B. alba and even M. mus-\nculus. Also it has name unknown before: Varanus bitatawa species"
    res = @neti.find(text)[:names]
    res.map do |name|
      verbatim = name[:verbatim]
      found_name = text[name[:offsetStart]..name[:offsetEnd]]
      found_name.should == verbatim
    end
  end

  it "should be able to return offsets for all names found by taxonfinder" do
    text = "We have to be sure that Betula\n alba and PSEUDOSCORPIONIDA and Aranea röselii and capitalized ARANEA RÖSELII and Pardosa\n moesta f. moesta Banks, 1892 all get their offsets"
    res = @neti.find(text)
    res.should == {:names=>[{:verbatim=>"Betula\n alba", :scientificName=>"Betula alba", :offsetStart=>24, :offsetEnd=>35}, {:verbatim=>"Aranea röselii", :scientificName=>"Aranea röselii", :offsetStart=>63, :offsetEnd=>76}, {:verbatim=>"Pardosa\n moesta", :scientificName=>"Pardosa moesta", :offsetStart=>113, :offsetEnd=>127}]}
    tf_res = @tf.find(text)
    tf_res.should == {:names=>[{:verbatim=>"Betula\n alba", :scientificName=>"Betula alba", :offsetStart=>24, :offsetEnd=>35}, {:verbatim=>"PSEUDOSCORPIONIDA", :scientificName=>"Pseudoscorpionida", :offsetStart=>41, :offsetEnd=>57}, {:verbatim=>"Aranea röselii", :scientificName=>"Aranea röselii", :offsetStart=>63, :offsetEnd=>76}, {:verbatim=>"ARANEA", :scientificName=>"Aranea", :offsetStart=>94, :offsetEnd=>99}, {:verbatim=>"Pardosa\n moesta f. moesta", :scientificName=>"Pardosa moesta f. moesta", :offsetStart=>113, :offsetEnd=>137}]}
  end

  it "should not make unsequential offsets on a page when using NetiNeti" do
    text = open(File.join(File.dirname(__FILE__), 'files', 'journalofentomol13pomo_0063.txt'), 'r:utf-8').read
    res = @neti.find(text)
    offsets = res[:names].map {|n| n[:offsetStart]}
    offsets.sort.should == offsets
    offsets[0].should == 67
  end

  it "should normalize capitalization of found names" do
    text = "We need to make sure that Ophioihrix nidis and OPHTOMVXIDAE and also  Ophiocynodus and especially ASTÉROCHEMIDAE and definitely STFROPHVTIDAE and may be Asleronyx excavata should all be capitalized correctly"
    res = @neti.find(text)
    res.should == {:names=>[{:verbatim=>"Ophioihrix nidis", :scientificName=>"Ophioihrix nidis", :offsetStart=>26, :offsetEnd=>41}, {:verbatim=>"OPHTOMVXIDAE", :scientificName=>"Ophtomvxidae", :offsetStart=>47, :offsetEnd=>58}, {:verbatim=>"Ophiocynodus", :scientificName=>"Ophiocynodus", :offsetStart=>70, :offsetEnd=>81}, {:verbatim=>"ASTÉROCHEMIDAE", :scientificName=>"Astérochemidae", :offsetStart=>98, :offsetEnd=>111}, {:verbatim=>"STFROPHVTIDAE", :scientificName=>"Stfrophvtidae", :offsetStart=>128, :offsetEnd=>140}, {:verbatim=>"Asleronyx excavata", :scientificName=>"Asleronyx excavata", :offsetStart=>153, :offsetEnd=>170}]}
  end

end
