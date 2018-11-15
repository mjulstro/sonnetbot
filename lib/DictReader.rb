require_relative 'Word.rb'

class DictReader

	# def initialize
	# 	@dict = Hash.new { |hash, key| hash[key] = look_up_word(key) }
	# end

	# def look_up_word(key)
	# 	pronunciation_array = Array.new
	# 	File.foreach("/Users/Marie/Documents/GitHub/sonnetbot/lib/cmudict.txt") do |line|
	# 		# if there are multiple pronunciations in CMUdict
	# 		# for the word, this will find all of them
	# 		if line.start_with?(key.upcase) and [" ", "("].include?(line[key.length()])
	# 			# all the characters before the first " " in that
	# 			# string comprise the word; everything else is the
	# 			# pronunciation
	# 			pronunciation = line.split(' ')[1..-1].join(' ')
	# 			pronunciation_array << pronunciation
	# 		end
	# 	end
	# 	return pronunciation_array
	# end

	# def make_word_list(word_list)
	# 	# the word lists will be organized by part of speech
	# 	new_word_list = []

	# 	for spelling in word_list
	# 		new_word_list.push(make_single_word(spelling))
	# 	end

	# 	return new_word_list
	# end

	def self.initialize_lists(list_of_lists)
		# sort all the word lists alphabetically
		# and create new versions to return
		new_list_of_lists = Array.new
		for list in list_of_lists
			list = list.sort
			new_list_of_lists << Array.new
		end

		# initialize a hash of where we are in each sorted list
		listIndexDict = Hash.new { |hash, key| hash[key] = 0 }

		# iterate over the lines in the CMU Dict comparing them
		# to the word in the lists that's alphabetically first
		File.foreach("/Users/Marie/Documents/GitHub/sonnetbot/lib/cmudict.txt") do |line|
			
			#Initialize an array of the word we're on in each list
			curr_words = Array.new
			for list in list_of_lists
				this_index = listIndexDict[list]
				if this_index < list.length
					curr_words << list[this_index]
				end
			end

			# choose the word that comes first alphabetically out of all the lists
			key = curr_words.min
			# update the index of the list it came from;
			# this relies on the fact that everything in the lists
			# is in the same order
			part_of_speech = curr_words.index(key)
			listIndexDict[list_of_lists[part_of_speech]] += 1
			pronunciation_array = Array.new  # this word's pronunciations

			# if there are multiple pronunciations in CMUdict
			# for the word, this will find all of them
			if line.start_with?(key.upcase) and [" ", "("].include?(line[key.length()])
				# all the characters before the first " " in that
				# string comprise the word; everything else is the
				# pronunciation
				pronunciation = line.split(' ')[1..-1].join(' ')
				pronunciation_array << pronunciation
			end

			new_list_of_lists[part_of_speech] << Word.new(key, pronunciation_array)
		end

		puts "Done initializing the lists!"
		return new_list_of_lists
	end

end
