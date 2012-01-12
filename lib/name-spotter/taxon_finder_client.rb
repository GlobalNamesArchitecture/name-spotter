class NameSpotter
  class TaxonFinderClient < NameSpotter::Client
    def initialize(opts = { host: "0.0.0.0", port: "1234" })
      super
      # We keep track of the document to get accurate offsets.
      # Other methods such as keeping track of the character number
      #  didn't work so well due to the nature of TaxonFinder.
      @document = ""
    end

    def socket
      @socket ||= TCPSocket.open @host, @port
    end

    def find(str, from_web_form=false)
      return [] if str.nil? || str.empty?

      # These are for the data-send-back that happens in TaxonFinder
      @current_string = ''
      @current_string_state = ''
      @word_list_matches = 0

      words = str.split(/\s/)
      words.each do |word|
        # Since we split on whitespace, this addition of a " " char
        # allows us to keep the document accurate and is basically
        # replacing all \s matches with " "
        @document << word + " "
        unless word.empty?
          taxon_find(word)
        end
      end
      socket.close
      @socket = nil
      @document = ""
      @names
    end

    def taxon_find(word)
      input = "#{word}|#{@current_string}|#{@current_string_state}|#{@word_list_matches}|0"
        socket.write(input + "\n")
      if output = socket.gets
        response = parse_socket_response(output)
        return if not response

        unless response.return_string.blank?
          verbatim_string = response.return_string.sub(/\[.*\]/, '.')
          scientific_string = response.return_string
          add_name NameSpotter::ScientificName.new(verbatim_string, :start_position => @document.rindex(verbatim_string), :scientific_name => scientific_string)
        end
        unless response.return_string_2.blank?
          verbatim_string = response.return_string_2.sub(/\[.*\]/, '.')
          scientific_string = response.return_string_2
          add_name NameSpotter::ScientificName.new(verbatim_string, :start_position => @document.rindex(verbatim_string), :scientific_name => scientific_string)
        end
      end
    end

    def parse_socket_response(response)
      current_string, current_string_state, word_list_matches, return_string, return_score, return_string_2, return_score_2 = response.strip.split '|'
      @current_string = current_string
      @current_string_state = current_string_state
      @word_list_matches = word_list_matches
      @return_score = return_score
      if not return_string.blank? or not return_string_2.blank?
        OpenStruct.new( { :current_string       => current_string,
                       :current_string_state => current_string_state,
                       :word_list_matches    => word_list_matches,
                       :return_string        => return_string,
                       :return_score         => return_score,
                       :return_string_2      => return_string_2,
                       :return_score_2       => return_score_2 })
      else
        false
      end
    end
  end
end
