# encoding: utf-8
class NameSpotter
  class TaxonFinderClient < NameSpotter::Client
    def initialize(opts = { host: "0.0.0.0", port: "1234" })
      super
    end

    def find(str, from_web_form=false)
      @names = []
      @document_verbatim = str
      return [] if str.nil? || str.empty?

      # These are for the data-send-back that happens in TaxonFinder
      @current_string = ''
      @current_string_state = ''
      @word_list_matches = 0
      @cursor = 8.times.inject([]) { |res| res << ['',0, 0] }
      @current_index = nil
      words = str.split(/\s/)
      words.each do |word|
        if word.empty?
          @cursor[-1][2] = @cursor[-1][2] + 1
        else
          abbr_no_space =  word.match(/^([A-Z][a-z]?\.)([a-z|\p{Latin}]+)/)
          if abbr_no_space
            process_word(abbr_no_space[1], 0)
            process_word(word[abbr_no_space[1].size..-1], 1)
          else
            process_word(word, 1)
          end
        end
      end
      socket.close
      @socket = nil
      @names
    end
    
    private

    def process_word(word, word_separator_size)
      cursor_entry = [word, @cursor[-1][0].size + @cursor[-1][1] + @cursor[-1][2], word_separator_size]
      @cursor.shift
      @cursor << cursor_entry
      taxon_find(word)
    end

    def socket
      @socket ||= TCPSocket.open @host, @port
    end

    def taxon_find(word)
      input = "#{word}|#{@current_string}|#{@current_string_state}|#{@word_list_matches}|0"
        socket.write(input + "\n")
      if output = socket.gets
        response = parse_socket_response(output)
        return if not response
        
        [response.return_string, response.return_string_2].each_with_index do |str, i|
          next if !str || str.split(" ").size > 6
          verbatim_string, scientific_string, start_position = process_response(str, i)
          next if scientific_string.empty?
          add_name NameSpotter::ScientificName.new(verbatim_string, :start_position => start_position, :scientific_name => scientific_string)
        end
        @current_index = @current_string.empty? ? nil : @cursor[-1][1]
      end
    end

    def parse_socket_response(response)
      current_string, current_string_state, word_list_matches, return_string, return_score, return_string_2, return_score_2 = response.strip.split '|'
      @current_string = current_string
      @current_string_state = current_string_state
      @word_list_matches = word_list_matches
      @return_score = return_score
      if !@current_index && @current_string.size > 0
          @current_index = @cursor[-1][1]
      end
      if not return_string.blank? or not return_string_2.blank? 
        OpenStruct.new( { :current_string       => current_string,
                       :current_string_state => current_string_state,
                       :word_list_matches    => word_list_matches,
                       :return_string        => return_string,
                       :return_score         => return_score,
                       :return_string_2      => return_string_2,
                       :return_score_2       => return_score_2 })
      else
        @current_index = nil if @current_string.empty? && @current_index
        false
      end
    end

    def process_response(str, index)
      is_return_string2 = (index == 1)
      str.force_encoding('utf-8')
      start_position = verbatim_string = nil
      if @current_index
        start_position = is_return_string2 ? @cursor[-1][1] : @current_index
        indices = @cursor.map { |item| item[1] }
        verbatim_components = @cursor[indices.rindex(start_position)..-1]
        sci_name_items_num = str.split(" ").size
        verbatim_components = verbatim_components[0...sci_name_items_num]
        verbatim_string = verbatim_components.map {|w| w[0] + (" " * w[2])}.join("").gsub(/[\.\,\!\;]*\s*$/, '')
      else
        verbatim_string, start_position, space_size = @cursor[-1]
      end
      scientific_string = str
      [verbatim_string, scientific_string, start_position]
    end

  end
end
