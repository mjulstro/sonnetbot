require_relative 'Word.rb'

class DictReader

	def initialize_lists(list_of_lists)
		# sort all the word lists alphabetically
		# and create new versions to return
		@list_of_lists = Array.new
		new_list_of_lists = Array.new
		for list in list_of_lists
			@list_of_lists << list.sort_by { |word| word.downcase }
			new_list_of_lists << Array.new
		end

		# initialize a hash of where we are in each sorted list
		@list_index_dict = Hash.new { |hash, key| hash[key] = 0 }
		initialize_current_word_array  #first time: @next_word = a
		curr_word = @next_word  #curr_word = a
		initialize_current_word_array  #@next_word = "abandoned"

		# iterate over the lines in the CMU Dict comparing them
		# to the word in the lists that's alphabetically first
		File.foreach("/Users/Marie/Documents/GitHub/sonnetbot/lib/cmudict.txt") do |line|
			if @next_word == nil
				break
			# if there are multiple pronunciations in CMUdict
			# for the word, this will find all of them
			elsif line.start_with?(curr_word.upcase) and [" ", "("].include?(line[curr_word.length()])
				# all the characters before the first " " in that
				# string comprise the word; everything else is the
				# pronunciation
				pronunciation = line.split(' ')[1..-1].join(' ')
				@pronunciation_array << pronunciation

				# puts "Found " + curr_word + " as curr_word"
			elsif line.start_with?(@next_word.upcase) and [" ", "("].include?(line[@next_word.length()])
				# puts "Found " + @next_word + " as @next_word"

				word = Word.new(curr_word, @pronunciation_array)
				new_list_of_lists[@part_of_speech] << word
				curr_word = @next_word
				
				initialize_current_word_array

				pronunciation = line.split(' ')[1..-1].join(' ')
				@pronunciation_array << pronunciation
			 else
			 	if line.split(' ')[0] > @next_word.upcase
			 		initialize_current_word_array
			 	end
			end

		end

		puts "Done initializing the lists!"
		puts new_list_of_lists
		return new_list_of_lists
	end

	def initialize_current_word_array
		curr_words = Array.new
		for list in @list_of_lists  # loop over the part-of-speech lists
			this_index = @list_index_dict[list]  # find our place in this list
			if this_index < list.length  # if we haven't gotten to the end of this list

				word_to_be_added = list[this_index]
				if curr_words.include?(word_to_be_added)
					@list_index_dict[list] += 1
					word_to_be_added = list[this_index + 1]
				end
				curr_words << word_to_be_added
				
			end
		end

		if curr_words.empty?
			@next_word = nil
			return
		end
		# choose the word that comes first alphabetically out of all the lists
		@next_word = curr_words.min

		# update the index of the list it came from
		@part_of_speech = curr_words.index(@next_word)
		@list_index_dict[@list_of_lists[@part_of_speech]] += 1
		@pronunciation_array = Array.new  # this word's pronunciations

		puts curr_words
		puts "***************** " + @next_word + " *******************"
		puts
	end

end
