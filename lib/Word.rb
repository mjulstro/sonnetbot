class Word

	def initialize(spelling, pronunciation_array)
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
		return string
	end

	def get_spelling
		return @spelling
	end

	def get_pronunciations
		return @pronunciations
	end

	def get_stress_patterns
		return @stress_patterns
	end

	def get_nums_syllables
		return @nums_syllables
	end

	# maybe pronunciation should be an inner class or smth?
	# because pronunciations can have stress patterns and numbers of
	# syllables, but words can't? but that would be a waste of disk space

end