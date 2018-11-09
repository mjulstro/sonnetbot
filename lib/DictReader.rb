require_relative 'Word.rb'

class DictReader

	def initialize
		@dict = Hash.new { |hash, key| hash[key] = look_up_word(key) }
	end

	def look_up_word(key)
		pronunciation_array = Array.new
		File.foreach("/Users/Marie/Documents/GitHub/sonnetbot/lib/cmudict.txt") do |line|
			# if there are multiple pronunciations in CMUdict
			# for the word, this will find all of them
			if line.start_with?(key.upcase) and [" ", "("].include?(line[key.length()])
				# all the characters before the first " " in that
				# string comprise the word; everything else is the
				# pronunciation
				pronunciation = line.split(' ')[1..-1].join(' ')
				pronunciation_array << pronunciation
			end
		end
		return pronunciation_array
	end

	def make_word_list(word_list)
		# the word lists will be organized by part of speech
		new_word_list = []

		for spelling in word_list
			new_word_list.push(make_single_word(spelling))
		end

		return new_word_list
	end

	def make_single_word(spelling)
		pronunciations = @dict[spelling]
		stress_patterns = Array.new
		nums_syllables = Array.new
		
		for pronunciation in pronunciations
			stress_patterns << find_stress_pattern(pronunciation)
			nums_syllables << pronunciation.scan(/0|1|2/).size
		end

		return Word.new(spelling, pronunciations,
				stress_patterns, nums_syllables)
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

end
