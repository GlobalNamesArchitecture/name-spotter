describe "NameSpotter" do
  subject { NameSpotter }
  let(:neti) { subject.new(subject::NetiNetiClient.new()) }
  let(:tf) { subject.new(subject::TaxonFinderClient.new()) }
  let(:clients) { [neti, tf] }

  describe ".version" do
    it "returns version" do
      expect(subject.version).to match /\d+\.\d+\.\d+/
    end
  end

  describe ".english?" do
    let(:eng) { read("english.txt") }
    let(:eng2) { read("journalofentomol13pomo_0018.txt") }
    let(:eng3) { read("journalofentomol13pomo_0063.txt") }

    it "detects english" do
      100.times do
        expect(subject.english? eng).to be true
        expect(subject.english? eng2).to be true
        expect(subject.english? eng3).to be false
      end
    end
  end

  describe ".new" do
    it "works" do
      expect(neti).to be_kind_of NameSpotter
      expect(tf).to be_kind_of NameSpotter
    end
  end

  describe "#find" do
    context "empty text" do
      it "returns empty list" do
        clients.each do |c|
          expect(c.find(nil)).to eq({ names: [] })
          expect(c.find(nil, 'json')).to eq "{\"names\":[]}"
          expect(c.find(nil, "xml"))
                 .to eq "<?xml version=\"1.0\"?>\n<names/>\n"
          expect(c.find('', 'json')).to eq "{\"names\":[]}"
          expect(c.find('', "xml"))
                 .to eq "<?xml version=\"1.0\"?>\n<names/>\n"
        end
      end
    end

    context "text without sci names" do
      let(:text) { "one two three, no scientific names" }

      it "returns empty list" do
        clients.each do |c|
          expect(c.find(text)).to eq({ names: [] })
        end
      end
    end

    context "text with one sci name" do
      let(:text) { "Pardosa moesta" }

      it "returns empty list" do
        clients.each do |c|
          expect(c.find(text)[:names].size).to eq 1
        end
      end
    end

    context "text with several names" do
      let(:text) do
        "Some text   that has Betula\n alba and Mus musculus " \
        "and \neven B. alba and even M. mus-\nculus and " \
        "unicoded name Aranea röselii. Also it has name " \
        "unknown before: Varanus bitatawa"
      end
      let(:text2) do
        "Some another text that has Xysticus \ncanadensis and " \
        "Pardosa moesta and \neven X. canadensis and even " \
        "P. mo-\nesta."
      end

      it "returns names" do
        res = neti.find(text)[:names].map { |n| n[:scientificName] }
        expect(res).to eq ["Betula alba", "Mus musculus",
                           "B. alba", "Aranea röselii", "Varanus bitatawa"]
        res = tf.find(text)[:names].map { |n| n[:scientificName] }
        expect(res).to eq ["Betula alba", "Mus musculus",
                           "B[etula] alba", "Aranea röselii",
                           "Varanus"]
      end

      it "forgets previous searches" do
        res = neti.find(text)[:names].map { |n| n[:scientificName] }
        expect(res).to eq ["Betula alba", "Mus musculus",
                           "B. alba", "Aranea röselii", "Varanus bitatawa"]
        res = tf.find(text)[:names].map { |n| n[:scientificName] }
        expect(res).to eq ["Betula alba", "Mus musculus",
                           "B[etula] alba", "Aranea röselii",
                           "Varanus"]
        res = neti.find(text2)[:names].map { |n| n[:scientificName] }
        expect(res).to eq ['Xysticus canadensis', 'Pardosa moesta',
                           'X. canadensis']
        res = tf.find(text2)[:names].map { |n| n[:scientificName] }
        expect(res).to eq ['Xysticus canadensis', 'Pardosa moesta',
                           'X[ysticus] canadensis']
      end
    end

    context "offsets" do
      let(:text3) do
        "\r\r\n>':¥/. \r\nA text with multibyte characters " \
        "नेति नेति: Some text that has Betula\n alba and " \
        "Mus musculus and \neven B. alba and even M. " \
        "mus-\nculus. Also it has name " \
        "unknown before: Varanus bitatawa species"
      end
      let(:text4) do
        "We have to be sure that Betula\n alba and " \
        "PSEUDOSCORPIONIDA and ×Inkea which is not " \
        "Passeriformes. We also have another hybrid Passiflora " \
        "×rosea and Aranea röselii and capitalized ARANEA " \
        "RÖSELII and Pardosa\n moesta f. moesta Banks, 1892 " \
        "all get their offsets"
      end
      let(:text5) { read "journalofentomol13pomo_0063.txt" }

      it "return correct names with multibyte chars" do
        # this test depends on netineti tornado server, not on
        # namespotter itself. Go and fix that!
        # the issue and the fix: https://github.com/mbl-cli/NetiNeti/pull/1
        res = neti.find(text3)[:names]
        res.map do |name|
          verbatim = name[:verbatim]
          found_name = text3[name[:offsetStart]..name[:offsetEnd]]
          expect(found_name).to eq verbatim
        end
      end

      it "returns offset for all names" do
        res = neti.find(text4)
        tf_res = tf.find(text4)
        expect(res).to eq({names: [
          {verbatim: "Betula\n alba", scientificName: "Betula alba",
           offsetStart: 24, offsetEnd: 35},
          {verbatim: "Passiflora ×rosea", scientificName: "Passiflora ×rosea",
          offsetStart: 126, offsetEnd: 142},
          {verbatim: "Aranea röselii", scientificName: "Aranea röselii",
          offsetStart: 148, offsetEnd: 161},
          {verbatim: "Pardosa\n moesta", scientificName: "Pardosa moesta",
          offsetStart: 198, offsetEnd: 212}
        ]})
        expect(tf_res).to eq({names: [
          {verbatim: "Betula  alba", scientificName: "Betula alba",
           offsetStart: 24, offsetEnd: 35},
          {verbatim: "PSEUDOSCORPIONIDA",
           scientificName: "Pseudoscorpionida", offsetStart: 41,
           offsetEnd: 57},
          {verbatim: "Passeriformes.", scientificName: "Passeriformes",
           offsetStart: 83, offsetEnd: 96},
          {verbatim: "Passiflora ×rosea", scientificName: "Passiflora rosea",
           offsetStart: 126, offsetEnd: 142},
          {verbatim: "Aranea röselii", scientificName: "Aranea röselii",
           offsetStart: 148, offsetEnd: 161},
          {verbatim: "ARANEA", scientificName: "Aranea", offsetStart: 179,
           offsetEnd: 184},
          {verbatim: "Pardosa  moesta f. moesta", scientificName:
           "Pardosa moesta f. moesta", offsetStart: 198, offsetEnd: 222}
        ]})
      end

      it "makes offsets in order with netineti" do
        res = neti.find(text5)
        offsets = res[:names].map { |n| n[:offsetStart] }
        expect(offsets).to eq offsets
        expect(offsets[0]).to eq 67
      end
    end
  end

  context "abbreviations" do
    let(:text) do
      "Pardosa moesta Banks, 1892 is one spider, Schizocosa " \
      "ocreata Keyserling, 1887 is a second and a third is " \
      "Schizocosa saltatrix borealis. The abbreviations are P. " \
      "moesta, S. ocreata, and S. saltatrix borealis is the third."
    end
    let(:text2) do
      "Pardosa moesta! If we encounter Pardosa moesta and then P.modica " \
      "another name I know is Xenopus laevis and also P.moesta. Again " \
      "without space TaxonFinder should find both. And Plantago major foreva"
    end
    let(:text3) do
      "What  happens another called P. (LYCOSIDAE) is the species?"
    end

    it "ignores abbreviated genus before family for TaxonFinder" do
      res = tf.find(text3)
      expect(res[:names].size).to be 1
      expect(res).to eq(
        {names: [{verbatim: "(LYCOSIDAE)", scientificName: "Lycosidae",
                  offsetStart: 32, offsetEnd: 42}]}
      )
    end

    it "preserves TaxonFinder expansions" do
      tf_res = tf.find(text)
      expect(tf_res).to eq(
        {names: [
          {verbatim: "Pardosa moesta", scientificName: "Pardosa moesta",
           offsetStart: 0, offsetEnd: 13},
          {verbatim: "Schizocosa ocreata",
           scientificName: "Schizocosa ocreata", offsetStart: 42,
           offsetEnd: 59},
          {verbatim: "Schizocosa saltatrix borealis",
           scientificName: "Schizocosa saltatrix borealis",
           offsetStart: 105, offsetEnd: 133},
          {verbatim: "P. moesta", scientificName: "P[ardosa] moesta",
           offsetStart: 158, offsetEnd: 166},
          {verbatim: "S. ocreata", scientificName: "S[chizocosa] ocreata",
           offsetStart: 169, offsetEnd: 178},
          {verbatim: "S. saltatrix borealis",
           scientificName: "S[chizocosa] saltatrix borealis",
           offsetStart: 185, offsetEnd: 205}]}
      )
    end


    it "recognizes abbreviations no space (TF)" do
      res = tf.find(text2)
      expect(res).to eq(
        {names: [
          {verbatim: "Pardosa moesta", scientificName: "Pardosa moesta",
           offsetStart: 0, offsetEnd: 13},
          {verbatim: "Pardosa moesta", scientificName: "Pardosa moesta",
           offsetStart: 32, offsetEnd: 45},
          {verbatim: "P.modica", scientificName: "P[ardosa] modica",
           offsetStart: 56, offsetEnd: 63},
          {verbatim: "Xenopus laevis", scientificName: "Xenopus laevis",
           offsetStart: 88, offsetEnd: 101},
          {verbatim: "P.moesta", scientificName: "P[ardosa] moesta",
           offsetStart: 112, offsetEnd: 119},
          {verbatim: "Plantago major", scientificName: "Plantago major",
           offsetStart: 176, offsetEnd: 189}]}
      )
      res[:names].map do |name|
        verbatim = name[:verbatim]
        found_name = text2[name[:offsetStart]..name[:offsetEnd]]
        expect(found_name).to eq verbatim
      end
    end
  end

  context "capitalization" do
    #this is a problem we are aware of
    let(:text) do
      "We need to make sure that Ophioihrix nidis and " \
      "OPHTOMVXIDAE and also  Ophiocynodus and especially " \
      "ASTÉROCHEMIDAE and definitely STFROPHVTIDAE and may be " \
      "Asleronyx excavata should all be capitalized correctly"
    end

    it "does not change capitalization" do
      res = neti.find(text)
      expect(res).to eq(
        {names: [
          {verbatim: "Ophioihrix nidis", scientificName: "Ophioihrix nidis",
          offsetStart: 26, offsetEnd: 41},
          {verbatim: "OPHTOMVXIDAE", scientificName: "OPHTOMVXIDAE",
          offsetStart: 47, offsetEnd: 58},
          {verbatim: "Ophiocynodus", scientificName: "Ophiocynodus",
          offsetStart: 70, offsetEnd: 81},
          {verbatim: "ASTÉROCHEMIDAE", scientificName: "ASTÉROCHEMIDAE",
          offsetStart: 98, offsetEnd: 111},
          {verbatim: "STFROPHVTIDAE", scientificName: "STFROPHVTIDAE",
          offsetStart: 128, offsetEnd: 140},
          {verbatim: "Asleronyx excavata", scientificName: "Asleronyx excavata",
          offsetStart: 153, offsetEnd: 170}
        ]}
      )
    end
  end

  context "OCR errors" do
    let(:pipe) do
      "We need to make sure that Oph|oihrix nidis and " \
      "OPHTOMVX|DAE will not break results"
    end

    it "substitutes | with l" do
      res = neti.find(pipe)
      expect(res).to eq(
        { names: [{ verbatim: "Ophloihrix nidis",
                    scientificName: "Ophloihrix nidis",
                    offsetStart: 26, offsetEnd: 41 }] }
      )
    end
  end

  context "extremely nexted infraspecies" do
    let(:text) do
      "If we encounter Plantago major it is ok, but if it is " \
      "Plantago quercus quercus quercus quercus quercus quercus " \
      "quercus quercus quercus quercus quercus quercus quercus " \
      "quercus, something is probably not right. However we take " \
      "Plantago quercus quercus quercus quercus quercus by some " \
      "strange reason. Well, the reason is this kind of thing -- " \
      "Pardosa moesta var. moesta f. moesta or something like that"
    end

    it "stops at five infraspecies levels" do
      res = tf.find(text)
      expect(res).to eq(
        {names: [
          {verbatim: "Plantago major", scientificName: "Plantago major",
          offsetStart: 16, offsetEnd: 29},
          {verbatim: "Plantago quercus quercus quercus quercus quercus",
          scientificName: "Plantago quercus quercus quercus quercus quercus",
          offsetStart: 225, offsetEnd: 272},
          {verbatim: "Pardosa moesta var. moesta f. moesta",
          scientificName: "Pardosa moesta var. moesta f. moesta",
          offsetStart: 340, offsetEnd: 375}]}
      )
    end
  end

  context "nested names" do
    let(:text) do
      "What  happens another called Pardosa moesta (Araneae: Lycosidae) is " \
      "the species?"
    end

    it "(TF) handles nested names in one cycle" do
      res = tf.find(text)
      expect(res).to eq (
        {names: [
          {verbatim: "Pardosa moesta", scientificName: "Pardosa moesta",
           offsetStart: 29, offsetEnd: 42},
          {verbatim: "(Araneae:", scientificName: "Araneae",
           offsetStart: 44, offsetEnd: 52},
          {verbatim: "Lycosidae)", scientificName: "Lycosidae",
           offsetStart: 54, offsetEnd: 63}]}
      )
    end
  end

  context "diacritics" do
    let(:text) { "Mactra triangula Renieri. Fissurella nubécula Linnó." }

    it "finds names with diacrictics" do
      res = tf.find(text)
      expect(res[:names].size).to be 2
      expect(res).to eq(
        {names: [
          {verbatim: "Mactra triangula", scientificName: "Mactra triangula",
           offsetStart: 0, offsetEnd: 15},
          {verbatim: "Fissurella nubécula",
           scientificName: "Fissurella nubécula",
           offsetStart: 26, offsetEnd: 44}]}
      )
    end
  end

  def read(file)
    File.read(File.join(__dir__, "files", file))
  end
end
