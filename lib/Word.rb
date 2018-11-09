class Word

	def initialize(spelling, pronunciations,
		stress_patterns, nums_syllables)
		@spelling = spelling
		@pronunciations = pronunciations
		@stress_patterns = stress_patterns
		@nums_syllables = nums_syllables
		# @part_of_speech = part_of_speech
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