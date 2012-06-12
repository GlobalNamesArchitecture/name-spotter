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
      @cursor = 5.times.inject([]) { |res| res << ['',-1] }
      @current_index = nil
      words = str.split(/\s/)
      words.each do |word|
        if word.empty?
          @cursor[-1][0] << " "
        else
          cursor_entry = [word, 1 + @cursor[-1][0].size + @cursor[-1][-1]]
          @cursor.shift
          @cursor << cursor_entry
          taxon_find(word)
        end
      end
      socket.close
      @socket = nil
      @names
    end
    
    private

    def socket
      @socket ||= TCPSocket.open @host, @port
    end

    def taxon_find(word)
      input = "#{word}|#{@current_string}|#{@current_string_state}|#{@word_list_matches}|0"
        socket.write(input + "\n")
      if output = socket.gets
        response = parse_socket_response(output)
        return if not response

        unless response.return_string.blank?
          verbatim_string, scientific_string, start_position = process_response(response.return_string)
          add_name NameSpotter::ScientificName.new(verbatim_string, :start_position => start_position, :scientific_name => scientific_string)
        end
        unless response.return_string_2.blank?
          verbatim_string, scientific_string, start_position = process_response(response.return_string_2)
          add_name NameSpotter::ScientificName.new(verbatim_string, :start_position => start_position, :scientific_name => scientific_string)
        end
      end
    end

    def parse_socket_response(response)
      current_string, current_string_state, word_list_matches, return_string, return_score, return_string_2, return_score_2 = response.strip.split '|'
      @current_string = current_string
      @current_string_state = current_string_state
      @word_list_matches = word_list_matches
      @return_score = return_score
      if @current_string.size > 0 && !@current_index
        @current_index = @cursor[-1][-1]
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

    def process_response(str)
      str.force_encoding('utf-8')
      start_position = verbatim_string = nil
      if @current_index
        start_position = @current_index
        words, indices = @cursor.transpose
        verbatim_string = words[indices.index(start_position)...-1].join(" ")
        @current_index = nil
      else
        verbatim_string, start_position = @cursor[-1]
      end
      scientific_string = str
      [verbatim_string, scientific_string, start_position]
    end

  end
end
