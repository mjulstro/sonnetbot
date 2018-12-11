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

		# grammatical state variables
		@last_word = ""
		@complete_clause = false
		@plural = false

		# poetic state variables
		@curr_line = 0
		@curr_syllable = 0
		@rhyming_with = nil
		@meter = "x/x/x/x/x/"
		@rhyme_scheme = "ABABCDCDEFEFGG"
	end


	########## primary methods: the meat and bones ##########

	def make_sonnet(num_lines = 14, meter = "x/x/x/x/x/", rhyme_scheme = "ABABCDCDEFEFGG")
		@curr_line = 0
		@curr_syllable = 0
		@rhyming_with = nil
		@meter = meter
		@rhyme_scheme = rhyme_scheme

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
		while !scans?(word) or !rhymes?(word)
			word = pos.next
		end

		@curr_syllable += @curr_add  # the length of the pronunciation that scanned for the last word
		array << word

		if @curr_syllable >= @meter.length
			@curr_syllable = 0
			@curr_line += 1
			array << "NEWLINE"
			# puts array
			update_rhymes
		end

		return array
	end

	def update_rhymes
		# this_line = @rhyme_scheme.slice(@curr_line)
		# before = @rhyme_scheme.slice(0, @curr_line)

		# if before.include?(this_line)
		# 	line_num = before.index(this_line)
			
		# 	num_newlines_seen = 0
		# 	last_newline_seen = 0
		# 	while num_newlines_seen < line_num
		# 		intermediate_sonnet = @sonnet.slice((last_newline_seen + 1)..-1)
		# 		last_newline_seen = @sonnet.index("NEWLINE") - 1
		# 		num_newlines_seen += 1
		# 	end

		# 	ind = 1
		# 	word = intermediate_sonnet[last_newline_seen - ind]
		# 	while !word.is_a?(Word)
		# 		ind += 1
		# 		word = intermediate_sonnet[last_newline_seen - ind]
		# 	end
		# end

		# @rhyming_with = word
		# puts @rhyming_with
	end

	########## grammatical methods: for putting sentences together ##########

	def sentence
		for pos in @pos_hash.values
			pos.shuffle
			pos.reset  # so we don't get the same words being chosen every time
		end

		# puts "Starting a sentence!"

		sentence = clause
		decider = rand(4)
		while decider == 0
			decider = rand(4)
			(sentence << ",").concat(choose(@conjunctions)).concat(clause)
		end

		sentence << ["?", "!", "."].sample

		return sentence
	end

	def clause
		plural = false

		clause = subject
		decider = rand(4)
		while decider == 0
			decider = rand(4)
			clause << " and"
			@curr_syllable += 1
			clause.concat(subject)
			plural = true
		end

		# decider = rand(4)
		# while decider == 0
		# 	decider = rand(4)
		# 	clause.concat(prep_phrase)
		# end

		clause.concat(predicate(plural))
		decider = rand(4)
		while decider == 0
			decider = rand(4)
			clause << " and"
			@curr_syllable += 1
			clause.concat(predicate(plural))
		end

		# decider = rand(4)
		# while decider == 0
		# 	decider = rand(4)
		# 	clause.concat(prep_phrase)
		# end

		# puts clause
		return clause
	end

	def subject
		subj = Array.new

		# "My"
		decider = rand(6)
		if decider < 5
			subj.concat(choose(@prefixes))
		end

		# "My hungry, sweet"
		decider = rand(2)
		if decider == 0
			decider = rand(2)
			subj.concat(choose(@adjectives))
		end
		while decider == 0
			decider = rand(2)
			(subj << ",").concat(choose(@adjectives))
		end

		# "My hungry, sweet dog"
		subj.concat(choose(@nouns))

		# "My hungry, sweet dog with a green tail"
		decider = rand(4)
		while decider == 0
			decider = rand(4)
			subj.concat(prep_phrase)
		end

		# puts subj
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
		decider = rand(4)
		if decider == 0
			decider = rand(4)
			pred.concat(choose(@adverbs))
		end
		while decider == 0
			decider = rand(4)
			(pred << ",").concat(choose(@adverbs))
		end

		# "snorts widely, sleepily, joyfully in a park"
		decider = rand(4)
		while decider == 0
			decider = rand(4)
			pred.concat(prep_phrase)
		end

		# puts pred
		return pred
	end

	def prep_phrase
		phrase = Array.new

		phrase.concat(choose(@prepositions))
		phrase.concat(subject)

		# puts phrase
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
			if (stress_pattern == correct_stress and @curr_syllable + stress_pattern.length <= @meter.length) or (stress_pattern.length == 1)
				# if this word is chosen for the poem, this is how many
				# syllables we'll advance in the line
				@curr_add = stress_pattern.length
				return true
			end
		end
		return false
	end

	def rhymes?(word)
		if @rhyming_with == nil or @curr_syllable < @meter.length or rhymes_with?(word, @rhyming_with)
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

end
