require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "NameSpotter" do
  before(:all) do
    @neti_neti = NameSpotter::NetiNetiClient.new()
    @taxon_finder = NameSpotter::TaxonFinderClient.new()
    @spotter_neti = NameSpotter.new(@neti_neti)
    @spotter_tf = NameSpotter.new(@taxon_finder)
  end

  it "should exist" do
    @spotter_neti.is_a?(NameSpotter).should be_true
    @spotter_tf.is_a?(NameSpotter).should be_true
  end
end
