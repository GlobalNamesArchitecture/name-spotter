class NameSpotter
  class ScientificName
    attr_reader :verbatim, :scientific, :start_pos, :end_pos, :score

    def self.normalize(name)
      name = name.gsub(",", " ") 
      name.gsub(/\s+/, " ")
    end

    def initialize(verbatim_name, options={})
      @verbatim = verbatim_name
      if options[:start_position]
        @start_pos = options[:start_position]
        @end_pos = @start_pos + @verbatim.length - 1
      end
      @score = options[:score] if options[:score]
      @scientific = options[:scientific_name] if options[:scientific_name]
    end

    # Use this in specs
    def eql?(other_name)
      other_name.is_a?(Name) &&
        other_name.verbatim.eql?(verbatim) &&
        other_name.scientific.eql?(scientific) &&
        other_name.start_pos.eql?(start_pos) && 
        other_name.end_pos.eql?(end_pos) && 
        other_name.score.eql?(score)
    end

    def to_hash
      name_hash = {:verbatim => verbatim}
      name_hash[:scientificName] = scientific if scientific
      name_hash[:offsetStart] = start_pos if start_pos
      name_hash[:offsetEnd] = end_pos if end_pos
      name_hash
    end
  end
end
