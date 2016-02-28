describe NameSpotter::ScientificName do

  describe ".new" do
    it "calculates end_pos" do
      find_me = "M. musculus"
      name = NameSpotter::ScientificName.new(
        find_me, { start_position: 30, scientific_name: "Mus musculus" }
      )
      expect(name.end_pos).to eq(name.start_pos + find_me.length - 1)
    end

    it "handles unicode characters" do
      verbatim = "Slovenščina"
      name = NameSpotter::ScientificName.
        new(verbatim, { start_position: 48193 })
      expect(name.verbatim).to eq verbatim
      expect(name.end_pos).to eq(name.start_pos + verbatim.length - 1)
    end
  end
end
