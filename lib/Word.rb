class Word

	def initialize(spelling, pronunciations,
		stress_patterns, nums_syllables)
		@spelling = spelling
		@pronunciations = pronunciations
		@stress_patterns = stress_patterns
		@nums_syllables = nums_syllables
		# @part_of_speech = part_of_speech
	end

	# maybe pronunciation should be an inner class or smth?
	# because pronunciations can have stress patterns and numbers of
	# syllables, but words can't? but that would be a waste of disk space

end