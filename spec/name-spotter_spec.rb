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

  it "should find if a text is in english" do 
    eng = open(File.join(File.dirname(__FILE__), 'files', 'english.txt'), 'r:utf-8').read
    eng2 = open(File.join(File.dirname(__FILE__), 'files', 'english.txt'), 'r:utf-8').read
    eng3 = open(File.join(File.dirname(__FILE__), 'files', 'journalofentomol13pomo_0018.txt'), 'r:utf-8').read
    eng3 = open(File.join(File.dirname(__FILE__), 'files', 'journalofentomol13pomo_0063.txt'), 'r:utf-8').read
    
    not_eng = open(File.join(File.dirname(__FILE__), 'files', 'not_english.txt'), 'r:utf-8').read
    100.times do
      NameSpotter.english?(eng).should be_true
      NameSpotter.english?(eng2).should be_true
      NameSpotter.english?(eng3).should be_false
      NameSpotter.english?(not_eng).should be_false
    end
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
    text = "Some text   that has Betula\n alba and Mus musculus and \neven B. alba and even M. mus-\nculus and unicoded name Aranea röselii. Also it has name unknown before: Varanus bitatawa species"
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
    # this test depends on netineti tornado server, not on namespotter itself. Go and fix that!
    # the issue and the fix: https://github.com/mbl-cli/NetiNeti/pull/1
    text = "\r\r\n>':¥/. \r\nA text with multibyte characters नेति नेति:  Some text that has Betula\n alba and Mus musculus and \neven B. alba and even M. mus-\nculus. Also it has name unknown before: Varanus bitatawa species"
    res = @neti.find(text)[:names]
    res.map do |name|
      verbatim = name[:verbatim]
      found_name = text[name[:offsetStart]..name[:offsetEnd]]
      found_name.should == verbatim
    end
  end

  it "should be able to return offsets for all names" do
    text = "We have to be sure that Betula\n alba and PSEUDOSCORPIONIDA and ×Inkea which is not Passeriformes. We also have another hybrid Passiflora ×rosea and Aranea röselii and capitalized ARANEA RÖSELII and Pardosa\n moesta f. moesta Banks, 1892 all get their offsets"
    res = @neti.find(text)
    res.should == {:names=>[{:verbatim=>"Betula\n alba", :scientificName=>"Betula alba", :offsetStart=>24, :offsetEnd=>35}, {:verbatim=>"Passiflora ×rosea", :scientificName=>"Passiflora ×rosea", :offsetStart=>126, :offsetEnd=>142}, {:verbatim=>"Aranea röselii", :scientificName=>"Aranea röselii", :offsetStart=>148, :offsetEnd=>161}, {:verbatim=>"Pardosa\n moesta", :scientificName=>"Pardosa moesta", :offsetStart=>198, :offsetEnd=>212}]}
    tf_res = @tf.find(text)
    tf_res.should == {:names=>[{:verbatim=>"Betula  alba", :scientificName=>"Betula alba", :offsetStart=>24, :offsetEnd=>35}, {:verbatim=>"PSEUDOSCORPIONIDA", :scientificName=>"Pseudoscorpionida", :offsetStart=>41, :offsetEnd=>57}, {:verbatim=>"Passeriformes.", :scientificName=>"Passeriformes", :offsetStart=>83, :offsetEnd=>96}, {:verbatim=>"Passiflora ×rosea", :scientificName=>"Passiflora rosea", :offsetStart=>126, :offsetEnd=>142}, {:verbatim=>"Aranea röselii", :scientificName=>"Aranea röselii", :offsetStart=>148, :offsetEnd=>161}, {:verbatim=>"ARANEA", :scientificName=>"Aranea", :offsetStart=>179, :offsetEnd=>184}, {:verbatim=>"Pardosa  moesta f. moesta", :scientificName=>"Pardosa moesta f. moesta", :offsetStart=>198, :offsetEnd=>222}]} 
  end
  
  it "should properly handle abbreviated names found by taxonfinder" do
    text = "Pardosa moesta Banks, 1892 is one spider, Schizocosa ocreata Keyserling, 1887 is a second and a third is Schizocosa saltatrix borealis. The abbreviations are P. moesta, S. ocreata, and S. saltatrix borealis is the third."
    tf_res = @tf.find(text)
    tf_res.should == {:names=>[{:verbatim=>"Pardosa moesta", :scientificName=>"Pardosa moesta", :offsetStart=>0, :offsetEnd=>13}, {:verbatim=>"Schizocosa ocreata", :scientificName=>"Schizocosa ocreata", :offsetStart=>42, :offsetEnd=>59}, {:verbatim=>"Schizocosa saltatrix borealis", :scientificName=>"Schizocosa saltatrix borealis", :offsetStart=>105, :offsetEnd=>133}, {:verbatim=>"P. moesta", :scientificName=>"P[ardosa] moesta", :offsetStart=>158, :offsetEnd=>166}, {:verbatim=>"S. ocreata", :scientificName=>"S[chizocosa] ocreata", :offsetStart=>169, :offsetEnd=>178}, {:verbatim=>"S. saltatrix borealis", :scientificName=>"S[chizocosa] saltatrix borealis", :offsetStart=>185, :offsetEnd=>205}]}
  end

  it "should not make unsequential offsets on a page when using NetiNeti" do
    text = open(File.join(File.dirname(__FILE__), 'files', 'journalofentomol13pomo_0063.txt'), 'r:utf-8').read
    res = @neti.find(text)
    offsets = res[:names].map {|n| n[:offsetStart]}
    offsets.sort.should == offsets
    offsets[0].should == 67
  end

  it "should not normalize capitalization of found names" do
    #this is a problem we are aware of
    text = "We need to make sure that Ophioihrix nidis and OPHTOMVXIDAE and also  Ophiocynodus and especially ASTÉROCHEMIDAE and definitely STFROPHVTIDAE and may be Asleronyx excavata should all be capitalized correctly"
    res = @neti.find(text)
    res.should == {:names=>[{:verbatim=>"Ophioihrix nidis", :scientificName=>"Ophioihrix nidis", :offsetStart=>26, :offsetEnd=>41}, {:verbatim=>"OPHTOMVXIDAE", :scientificName=>"OPHTOMVXIDAE", :offsetStart=>47, :offsetEnd=>58}, {:verbatim=>"Ophiocynodus", :scientificName=>"Ophiocynodus", :offsetStart=>70, :offsetEnd=>81}, {:verbatim=>"ASTÉROCHEMIDAE", :scientificName=>"ASTÉROCHEMIDAE", :offsetStart=>98, :offsetEnd=>111}, {:verbatim=>"STFROPHVTIDAE", :scientificName=>"STFROPHVTIDAE", :offsetStart=>128, :offsetEnd=>140}, {:verbatim=>"Asleronyx excavata", :scientificName=>"Asleronyx excavata", :offsetStart=>153, :offsetEnd=>170}]}
  end
  
  it "should not break NetiNeti results from processing OCR with | character in it" do
    text = "We need to make sure that Oph|oihrix nidis and OPHTOMVX|DAE will not break results"
    res = @neti.find(text)
    res.should == {:names=>[{:verbatim=>"Ophloihrix nidis", :scientificName=>"Ophloihrix nidis", :offsetStart=>26, :offsetEnd=>41}]}
  end

  it "should not parse ridiculously long infraspecies names by taxon finder" do
    text = "If we encounter Plantago major it is ok, but if it is Plantago quercus quercus quercus quercus quercus quercus quercus quercus quercus quercus quercus quercus quercus quercus, something is probably not right. However we take Plantago quercus quercus quercus quercus quercus by some strange reason. Well, the reason is this kind of thing -- Pardosa moesta var. moesta f. moesta or something like that"
    res = @tf.find(text)
    res.should == {:names=>[{:verbatim=>"Plantago major", :scientificName=>"Plantago major", :offsetStart=>16, :offsetEnd=>29}, {:verbatim=>"Plantago quercus quercus quercus quercus quercus", :scientificName=>"Plantago quercus quercus quercus quercus quercus", :offsetStart=>225, :offsetEnd=>272}, {:verbatim=>"Pardosa moesta var. moesta f. moesta", :scientificName=>"Pardosa moesta var. moesta f. moesta", :offsetStart=>340, :offsetEnd=>375}]}
  end

  it "should be able to recognize names like P.moesta by TaxonFinder" do
    text = "Pardosa moesta! If we encounter Pardosa moesta and then P.modica another name I know is Xenopus laevis and also P.moesta. Again without space TaxonFinder should find both. And Plantago major foreva"
    res = @tf.find(text)
    res.should == {:names=>[{:verbatim=>"Pardosa moesta", :scientificName=>"Pardosa moesta", :offsetStart=>0, :offsetEnd=>13}, {:verbatim=>"Pardosa moesta", :scientificName=>"Pardosa moesta", :offsetStart=>32, :offsetEnd=>45}, {:verbatim=>"P.modica", :scientificName=>"P[ardosa] modica", :offsetStart=>56, :offsetEnd=>63}, {:verbatim=>"Xenopus laevis", :scientificName=>"Xenopus laevis", :offsetStart=>88, :offsetEnd=>101}, {:verbatim=>"P.moesta", :scientificName=>"P[ardosa] moesta", :offsetStart=>112, :offsetEnd=>119}, {:verbatim=>"Plantago major", :scientificName=>"Plantago major", :offsetStart=>176, :offsetEnd=>189}]}
    res[:names].map do |name|
      verbatim = name[:verbatim]
      found_name = text[name[:offsetStart]..name[:offsetEnd]]
      found_name.should == verbatim
    end
 end
  
  it "should register situations where new name started and prev name is finished in the same cycle in TF" do
    text = "What  happens another called Pardosa moesta (Araneae: Lycosidae) is the species?"
    res = @tf.find(text)
    res.should == {:names=>[{:verbatim=>"Pardosa moesta", :scientificName=>"Pardosa moesta", :offsetStart=>29, :offsetEnd=>42}, {:verbatim=>"(Araneae:", :scientificName=>"Araneae", :offsetStart=>44, :offsetEnd=>52}, {:verbatim=>"Lycosidae)", :scientificName=>"Lycosidae", :offsetStart=>54, :offsetEnd=>63}]} 
  end

  it "should ignore abbreviated genus before family for TaxonFinder" do
    text = "What  happens another called P. (LYCOSIDAE) is the species?"
    res = @tf.find(text)
    res[:names].size.should == 1
    res.should == {:names=>[{:verbatim=>"(LYCOSIDAE)", :scientificName=>"Lycosidae", :offsetStart=>32, :offsetEnd=>42}]}
  end
  
  it "should find names with diacrictics" do
    text = 'Mactra triangula Renieri. Fissurella nubécula Linnó.'
    res = @tf.find(text)
    res[:names].size.should == 2 
    res.should == {:names=>[{:verbatim=>"Mactra triangula", :scientificName=>"Mactra triangula", :offsetStart=>0, :offsetEnd=>15}, {:verbatim=>"Fissurella nubécula", :scientificName=>"Fissurella nubécula", :offsetStart=>26, :offsetEnd=>44}]} 
  end

end
