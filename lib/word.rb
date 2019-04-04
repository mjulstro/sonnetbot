require_relative 'dict_reader.rb'

class Word

	def initialize(spelling, pronunciation_array, pos)
		stress_patterns = Array.new
		nums_syllables = Array.new

		for pronunciation in pronunciation_array
			stress_patterns << find_stress_pattern(pronunciation)
			nums_syllables << pronunciation.scan(/0|1|2/).size
		end

		@spelling = spelling
		@pronunciations = pronunciation_array
		@stress_patterns = stress_patterns
		@nums_syllables = nums_syllables
		@part_of_speech = pos
	end

	def find_stress_pattern(pronunciation)
		# example pronunciation string: "AE1 D M ER0 AH0 B AH0 L"
		sounds = pronunciation.split(" ")
		stress_pattern = ""
		for sound in sounds
			if sound.include?("1") or sound.include?("2")
				stress_pattern << "/"
			elsif sound.include?("0")
				stress_pattern << "x"
			end
		end
		return stress_pattern
	end

	def to_s
		string = @spelling + "\n"
		for list in [@pronunciations, @stress_patterns, @nums_syllables]
			for item in list
				string << item.to_s + " "
			end
			string << "\n"
		end
		string << "\n"
		return string
	end

	# @param [Object] word
	# @return [Array] last_syls
	def last_syls
	# puts_all_state(word.spelling)
	last_syls = []
	ind = 0
	@pronunciations.each do |pronunciation|
	  ind += 1
	  begin
	    # pron_length = word.stress_patterns[word.pronunciations.index pronunciation].length
	    # if @curr_syllable + pron_length <= @meter.length - 1
	    #   return true
	    #   # return true if this word doesn't put Fus at the end of the line
	    # end

	    last_syl_start = pronunciation.rindex(/\d/) - 2
	    last_syl = pronunciation.slice(last_syl_start..pronunciation.length)
	    last_syl = last_syl.tr('012', '') # removes stress information; this should be accounted for by the scansion
	    last_syls << last_syl
	  rescue StandardError
	    # usually an error will be thrown if the pronunciations list is too long for
	    # some reason. In this case, the pronunciations list should be shortened.
	    shorten_prons ind
	  end
	end
	last_syls
	end

	def spelling
		@spelling
	end

	def pronunciations
		@pronunciations
	end

	def shorten_prons(n)
		@pronunciations = @pronunciations.first(n)
	end

	def stress_patterns
		@stress_patterns
	end

	def nums_syllables
		@nums_syllables
	end

	def part_of_speech
		@part_of_speech
	end

	# maybe pronunciation should be an inner class or smth?
	# because pronunciations can have stress patterns and numbers of
	# syllables, but words can't?

end
