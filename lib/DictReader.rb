class DictReader

	def initialize
		@dict
		read_dict
	end

	def read_dict
	# create a dictionary of <spelling, [pronunciations]>
	# for each line in cmudict.txt
		# if the line does not begin with punctuation
			# the line is a string

			# all the characters before the first " " in that
			# string comprise the word; everything else is the
			# pronunciation

			# add to dict <word, pronunciation>

			# if the word ends in (1)
				# add its pronunciation to the value in the dict
				# for the version if it that doesn't have (1)
			# end

		# end
	end

	def make_word_list(word_list)
		# the word lists will be organized by part of speech
		new_word_list = []

		for word in word_list
			# find the word's pronunciation(s) in cmudict and save them

			# for each pronunciation
				find_stress_pattern(pronunciation)
				# add that to a list of pronunciations
				# count the number of syllables in the stress pattern
				# and add that to a list of numbers of syllables

			new_word_list.add(Word(spelling, pronunciations,
				stress_patterns, nums_syllables))
		end

		return new_word_list
	end

	def find_stress_pattern(pronunciation)
		# takes in a pronunciation string and parses stress patterns from it

		# example pronunciation string: "AE1 D M ER0 AH0 B AH0 L"
	end

end