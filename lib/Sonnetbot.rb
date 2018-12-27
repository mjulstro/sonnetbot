require_relative 'verbs.rb'
require_relative 'adjectives.rb'
require_relative 'adverbs.rb'
require_relative 'nouns.rb'
require_relative 'conjunctions.rb'
require_relative 'prepositions.rb'
require_relative 'Word.rb'
require_relative 'Part_of_Speech.rb'
require_relative 'DictReader.rb'

class Sonnetbot

	def initialize
		@dict_reader = DictReader.new
		# vocabulary
		prefixes = ["a", "the", "my", "your", "his", "her", "their", "our"]
		@pos_hash = @dict_reader.initialize_lists(prefixes,
			fill_adjectives, fill_nouns, fill_verbs, fill_adverbs,
			fill_conjunctions, fill_prepositions)
		@prefixes     = @pos_hash["prefixes"]
		@adjectives   = @pos_hash["adjectives"]
		@nouns        = @pos_hash["nouns"]
		@verbs        = @pos_hash["verbs"]
		@adverbs      = @pos_hash["adverbs"]
		@conjunctions = @pos_hash["conjunctions"]
		@prepositions = @pos_hash["prepositions"]
	end


	########## primary methods: the meat and bones ##########

	def make_sonnet(num_lines = 14, meter = "x/x/x/x/x/", rhyme_scheme = "ABABCDCDEFEFGG")
		@curr_line = 0
		@curr_syllable = 0
		@rhyming_with = nil
		@meter = meter
		@rhyme_scheme = rhyme_scheme
		@rhyme_dict = Hash.new
		@num_lines = num_lines

		@sonnet = Array.new

		# keep adding sentences to the sonnet
		# until we reach the last syllable of the last line
		while @curr_line <= @num_lines and @curr_syllable <= meter.length
			@sonnet.concat(sentence)
		end

		return to_text(@sonnet)
	end

	# def make_sentence
	# 	return sentence_to_text(sentence)
	# end

	def to_text(array)
		text = ""
		capital = true
		ind = 0
		skip_next = false
		for word in array
			if ["?", "!", "."].include?(word)
				if !skip_next
					text << word
				end
				skip_next = false
				capital = true
			elsif [",", " and"].include?(word)
				if !skip_next
					text << word
				end
				skip_next = false
				capital = false
			elsif word == "NEWLINE" or word == "\n"
				if ["?", "!", ".", ","].include?(array[ind + 1])
					text << array[ind + 1]
					skip_next = true
				end
				text << "\n"
			else
				if capital
					text << " " << word.spelling.capitalize
				else
					text << " " << word.spelling
				end
				capital = false
			end
			ind += 1
		end

		return text
	end

	def choose(pos)
		array = Array.new

		word = pos.next
		orig = word
		while !scans?(word) or !rhymes?(word)
			word = pos.next
			if word == orig
				array << nil
				break
			end
		end

		@curr_syllable += @curr_add  # the length of the pronunciation that scanned for the last word
		array << word

		puts "#{@curr_line}:#{@curr_syllable} #{word.spelling}"
		if @curr_syllable >= @meter.length
			update_rhymes(word)
			@curr_syllable = 0
			@curr_line += 1
			array << "NEWLINE"
			# puts array

			orig = word
			while !scans?(word) or !rhymes?(word)
				word = pos.next
				if word == orig
					array << nil
					break
				end
			end
		end

		return array
	end

	def update_rhymes(word)
		# assign this word to be the rhyme for this letter
		letter = @rhyme_scheme[@curr_line]
		if letter != nil and !@rhyme_dict.include?(letter)
			@rhyme_dict[letter] = word
		end

		# assign @rhyming_with according to the next line in the rhyme scheme
		letter2 = @rhyme_scheme[@curr_line + 1]
		if letter2 != nil and @rhyme_dict.include?(letter2)
			@rhyming_with = @rhyme_dict[letter2]
		end

		begin
			puts "*******************#{@curr_line + 1}, #{letter2}, #{@rhyming_with.spelling}, #{@rhyme_dict[letter2].spelling}"
		rescue
			# if @rhyming_with or @rhyme_dict[letter] is nil
			puts "*******************#{@curr_line + 1}, #{letter2}"
		end
	end

	########## grammatical methods: for putting sentences together ##########

	def sentence
		syl = @curr_syllable
		line = @curr_line
		for i in 0..5
			for pos in @pos_hash.values
				pos.shuffle
				pos.reset  # so we don't get the same words being chosen every time
			end

			# puts "Starting a sentence!"

			sentence = clause
			while rand(4) == 0 and @curr_line < @num_lines
				(sentence << ",").concat(choose(@conjunctions)).concat(clause)
			end

			sentence << ["?", "!", "."].sample

			if !sentence.include?(nil)
				return sentence
			end
			@curr_syllable = syl
			@curr_line = line
		end
	end

	def clause
		line = @curr_line
		syl = @curr_syllable
		for i in 0..5
			plural = false
			clause = Array.new

			while rand(4) == 0 and @curr_line < @num_lines
				clause.concat(prep_phrase)
			end

			clause.concat(subject)
			while rand(4) == 0 and @curr_line < @num_lines
				clause << " and"
				@curr_syllable += 1
				clause.concat(subject)
				plural = true
			end

			clause.concat(predicate(plural))
			while rand(4) == 0 and @curr_line < @num_lines
				clause << " and"
				@curr_syllable += 1
				clause.concat(predicate(plural))
			end

			if !clause.include?(nil)
				return clause
			end
			@curr_line = line
			@curr_syllable = syl
		end
		return (Array.new) << nil
	end

	def subject
		line = @curr_line
		syl = @curr_syllable
		for i in 0..5
			subj = Array.new

			# "My"
			if rand(6) < 5
				subj.concat(choose(@prefixes))
			end

			# "My hungry, sweet"
			if rand(2) == 0
				subj.concat(choose(@adjectives))
				while rand(2) == 0
					(subj << ",").concat(choose(@adjectives))
				end
			end

			# "My hungry, sweet dog"
			subj.concat(choose(@nouns))

			# "My hungry, sweet dog with a green tail"
			while rand(4) == 0 and @curr_line < @num_lines
				subj.concat(prep_phrase)
			end

			if !subj.include?(nil)
				return subj
			end
			@curr_line = line
			@curr_syllable = syl
		end
		return (Array.new) << nil
	end

	def predicate(plural)
		line = @curr_line
		syl = @curr_syllable
		if choose(@verbs).include?(nil)
			return (Array.new) << nil
		end
		for i in 0..5
			pred = Array.new

			# "snorts"
			if plural
				pred.concat(choose(@verbs))
			else
				# TODO: The commented-out part below is not
				# adapted to the fact that "choose" returns
				# an Array. Deal with this... someday

				# # this section is to protect against choosing a verb for its
				# # non-conjugated form, and then conjugating it and having it
				# # not scan or rhyme anymore
				# chosen = make_present_tense(choose(@verbs))
				# while !scans?(chosen) or !rhymes?(chosen)
				# 	chosen = make_present_tense(choose(@verbs))
				# end
				# pred.concat(chosen)
				pred.concat(make_present_tense(choose(@verbs)))
			end

			# "snorts widely, sleepily, joyfully"
			if rand(4) == 0
				pred.concat(choose(@adverbs))
				while rand(4) == 0
					(pred << ",").concat(choose(@adverbs))
				end

			end

			# "snorts widely, sleepily, joyfully in a park"
			while rand(4) == 0 and @curr_line < @num_lines
				pred.concat(prep_phrase)
			end

			if !pred.include?(nil)
				return pred
			end
			@curr_line = line
			@curr_syllable = syl
		end
		return (Array.new) << nil
	end

	def prep_phrase
		syl = @curr_syllable
		line = @curr_line
		for i in 0..5
			phrase = Array.new

			phrase.concat(choose(@prepositions))
			phrase.concat(subject)

			if !phrase.include?(nil)
				return phrase
			end
			@curr_line = line
			@curr_syllable = syl
		end
		return (Array.new) << nil
	end

	def make_present_tense(array)
		verb = array[0]
		if verb != nil
			if verb.spelling.end_with?("s") or verb.spelling.end_with?("h")
				new_verb = @dict_reader.single_word(verb.spelling + "es")
			else
				new_verb = @dict_reader.single_word(verb.spelling + "s")
			end

			array[0] = new_verb
		end
		return array
	end

	########## poetic methods: for choosing the right words ##########

	def scans?(word)
		for stress_pattern in word.stress_patterns
			correct_stress = @meter.slice(@curr_syllable, stress_pattern.length)
			if stress_pattern == correct_stress and @curr_syllable + stress_pattern.length <= @meter.length
				# if this word is chosen for the poem, this is how many
				# syllables we'll advance in the line
				@curr_add = stress_pattern.length
				return true
			elsif @curr_syllable < @meter.length and stress_pattern.length == 1
				@curr_add = stress_pattern.length
				return true
			end
		end
		return false
	end

	def rhymes?(word)
		if @rhyming_with == nil or (@curr_syllable + @curr_add) < @meter.length
			return true
		elsif rhymes_with?(word, @rhyming_with)
			return true
		else
			return false
		end
	end

	def rhymes_with?(word1, word2)
		if !(last_syls(word1) & last_syls(word2)).empty?
			# if there's an overlap in the ways the two words can be pronounced
			return true
		else
			return false
		end
	end

	def last_syls(word)
		# puts_all_state(word.spelling)
		last_syls = Array.new
		ind = 0
		for pronunciation in word.pronunciations
			ind += 1
			begin
				pron_length = word.stress_patterns[word.pronunciations.index(pronunciation)].length
				# if @curr_syllable + pron_length <= @meter.length - 1
				# 	return true
				# 	# return true if this word doesn't put us at the end of the line
				# end

				last_syl_start = pronunciation.rindex(/\d/) - 2
				last_syl = pronunciation.slice(last_syl_start..pronunciation.length)
				last_syl = last_syl.tr('012', '')  # removes stress information; this should be accounted for by the scansion
				last_syls << last_syl
			rescue
				# usually an error will be thrown if the pronunciations list is too long for
				# some reason. In this case, the pronunciations list should be shortened.
				word.shorten_prons(ind)
			end
		end
		return last_syls
	end

	def puts_all_state(input = nil)  # for debugging
		puts
		puts "*************DESCRIBING ENTIRE SONNETBOT STATE**************"
		puts "Line #{@curr_line}"
		puts "Syllable #{@curr_syllable}"
		if @rhyming_with == nil
			puts "Rhyming with nil"
		else
			puts "Rhyming with #{@rhyming_with.spelling}"
		end

		if input != nil
			puts input
		end
	end

end