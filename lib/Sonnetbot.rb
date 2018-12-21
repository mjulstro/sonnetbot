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

		@sonnet = Array.new

		# keep adding sentences to the sonnet
		# until we reach the last syllable of the last line
		while @curr_line <= num_lines and @curr_syllable <= meter.length
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
			elsif word == "NEWLINE"
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
			end
		end

		@curr_syllable += @curr_add  # the length of the pronunciation that scanned for the last word
		array << word

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
				end
			end
		end

		return array
	end

	def update_rhymes(word)
		puts_all_state(word.spelling)
		letter = @rhyme_scheme[@curr_line]

		if @rhyme_dict.include?(letter)
			@rhyming_with = @rhyme_dict[letter]
		else
			@rhyme_dict[letter] = word
			@rhyming_with = nil
		end
		puts_all_state
	end

	########## grammatical methods: for putting sentences together ##########

	def sentence
		for pos in @pos_hash.values
			pos.shuffle
			pos.reset  # so we don't get the same words being chosen every time
		end

		# puts "Starting a sentence!"

		sentence = clause
		while rand(4) == 0
			(sentence << ",").concat(choose(@conjunctions)).concat(clause)
		end

		sentence << ["?", "!", "."].sample

		return sentence
	end

	def clause
		plural = false
		clause = Array.new

		while rand(4) == 0
			clause.concat(prep_phrase)
		end

		clause.concat(subject)
		while rand(4) == 0
			clause << " and"
			@curr_syllable += 1
			clause.concat(subject)
			plural = true
		end

		clause.concat(predicate(plural))
		while rand(4) == 0
			clause << " and"
			@curr_syllable += 1
			clause.concat(predicate(plural))
		end

		return clause
	end

	def subject
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
		while rand(4) == 0
			subj.concat(prep_phrase)
		end

		return subj
	end

	def predicate(plural)
		pred = Array.new

		# "snorts"
		if plural
			pred.concat(choose(@verbs))
		else
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
		while rand(4) == 0
			pred.concat(prep_phrase)
		end

		return pred
	end

	def prep_phrase
		phrase = Array.new

		phrase.concat(choose(@prepositions))
		phrase.concat(subject)

		return phrase
	end

	def make_present_tense(array)
		verb = array[0]
		if verb.spelling.end_with?("s") or verb.spelling.end_with?("h")
			new_verb = @dict_reader.single_word(verb.spelling + "es")
		else
			new_verb = @dict_reader.single_word(verb.spelling + "s")
		end

		array[0] = new_verb
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
		for pronunciation in word.pronunciations
			pron_length = word.stress_patterns[word.pronunciations.index(pronunciation)].length
			# if @curr_syllable + pron_length <= @meter.length - 1
			# 	return true
			# 	# return true if this word doesn't put us at the end of the line
			# end

			last_syl_start = pronunciation.rindex(/\d/) - 2
			last_syl = pronunciation.slice(last_syl_start..pronunciation.length)
			last_syl = last_syl.tr('012', '')  # removes stress information; this should be accounted for by the scansion
			last_syls << last_syl
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