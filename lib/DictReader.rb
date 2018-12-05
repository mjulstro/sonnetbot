require_relative 'Word.rb'

class DictReader

	def initialize_lists(list_of_lists)
		# sort all the word lists alphabetically
		# and create new versions to return
		@list_of_lists = list_of_lists
		new_list_of_lists = Array.new
		for list in @list_of_lists
			list = list.sort
			new_list_of_lists << Array.new
		end

		# initialize a hash of where we are in each sorted list
		@list_index_dict = Hash.new { |hash, key| hash[key] = 0 }
		curr_words = initialize_current_word_array
		last_word = @key

		# iterate over the lines in the CMU Dict comparing them
		# to the word in the lists that's alphabetically first
		File.foreach("/Users/Marie/Documents/GitHub/sonnetbot/lib/cmudict.txt") do |line|

			# if there are multiple pronunciations in CMUdict
			# for the word, this will find all of them
			if line.start_with?(@key.upcase) and [" ", "("].include?(line[@key.length()])
				# all the characters before the first " " in that
				# string comprise the word; everything else is the
				# pronunciation
				pronunciation = line.split(' ')[1..-1].join(' ')
				puts pronunciation
				@pronunciation_array << pronunciation
				puts @pronunciation_array
				last_word = @key
			else
				if @key == last_word
					puts @pronunciation_array
					word = Word.new(@key, @pronunciation_array)
					new_list_of_lists[@part_of_speech] << word
					puts word

					initialize_current_word_array
					last_word = @key
				end
			end

		end

		puts "Done initializing the lists!"
		return new_list_of_lists
	end

	def initialize_current_word_array
		curr_words = Array.new
		for list in @list_of_lists
			this_index = @list_index_dict[list]
			if this_index < list.length
				curr_words << list[this_index]
			end
		end			

		# choose the word that comes first alphabetically out of all the lists
		@key = curr_words.min
		# update the index of the list it came from;
		# this relies on the fact that everything in the lists
		# is in the same order
		@part_of_speech = curr_words.index(@key)
		@list_index_dict[@list_of_lists[@part_of_speech]] += 1
		@pronunciation_array = Array.new  # this word's pronunciations
	end

end
