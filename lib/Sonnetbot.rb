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
		@rhyme_scheme = "ABAB CDCD EFEF GG"
	end


	########## primary methods: the meat and bones ##########

	def make_sonnet(num_lines = 14, meter = "x/x/x/x/x/", rhyme_scheme = "ABAB CDCD EFEF GG")
		@curr_line = 0
		@curr_syllable = 0
		@rhyming_with = nil
		@meter = meter
		@rhyme_scheme = rhyme_scheme

		sonnet = ""

		# keep adding sentences to the sonnet
		# until we reach the last syllable of the last line
		while !(@curr_line >= num_lines and @curr_syllable >= meter.length)
			sonnet = sonnet + " " + make_sentence
		end

		return sonnet
	end

	def make_sentence
		for pos in @pos_hash.values
			pos.shuffle
			pos.reset  # so we don't get the same words being chosen every time
		end

		puts "Starting a sentence!"
		@complete_clause = false
		@plural = false
		sentence = start_subject().spelling

		while @last_word != "punctuation"
			next_word = follow
			while !scans?(next_word) or !rhymes?(next_word)
				next_word = follow
			end
			@curr_syllable += @curr_add
			sentence = sentence + " " + next_word.spelling

			if @curr_syllable >= @meter.length
				sentence + sentence + "\n"
				@curr_syllable = 0
				@curr_line = @curr_line + 1
			end
		end

		return sentence.capitalize
	end

	def follow
		case @last_word
		when "noun"
			return follow_noun
		when "adjective"
			return follow_adjective
		when "prefix"
			return follow_prefix
		when "verb"
			return follow_verb
		when "adverb"
			return follow_adverb
		when "conjunction", "and"
			return follow_conjunction
		else
			puts "** Error! **"  #TODO: throw an exception here
		end
	end


	########## grammatical methods: for putting sentences together ##########

	def start_subject
		decider = rand(6)
		if decider == 0 then
			@last_word = "noun"
			return @nouns.next
		elsif decider == 1 then
			@last_word = "adjective"
			return @adjectives.next
		else
			@last_word = "prefix"
			return @prefixes.next
		end
	end

	def prepositional_phrase
		phrase = Array.new
		candidate = @prepositions.next
		while !@prepositions.done? and !scans?(candidate)
			candidate = @prepositions.next
		end
		phrase << candidate

		while @last_word != "noun" do
			phrase << follow
		end
		# we have now ended on a noun, and our prepositional
		# phrase is complete. Time to turn the list into a Word
		# that can be inserted into the poem.
		return phrase_to_word(phrase)
	end

	def follow_prefix
		decider = rand(4)
		if decider == 0 then
			@last_word = "adjective"
			return @adjectives.next
		else
			@last_word = "noun"
			return @nouns.next
		end
	end

	def follow_adjective
		decider = rand(4)
		if decider == 0 then
			@last_word = "adjective"
			return @adjectives.next
		else
			@last_word = "noun"
			return @nouns.next
		end
	end

	def follow_noun
		decider = rand(4)
		if decider == 0 then
			if @complete_clause == true
				@last_word = "conjunction"
				@complete_clause = false
				return @conjunctions.next
			else
				@last_word = "and"
				@curr_syllable = @curr_syllable + 1
				return Word.new("and", ["AH0 N D"])
			end
		elsif decider == 1 then
			return prepositional_phrase
		else
			@last_word = "verb"
			@complete_clause = true
			if @plural == true then
				return @verbs.next
			else
				return make_present_tense(@verbs.next)
			end
		end
	end

	def follow_verb
		decider = rand(4)
		if decider == 0 then
			@last_word = "adverb"
			return @adverbs.next
		elsif decider == 1 then
			decider2 = rand(4)
			if decider2 == 0
				@last_word = "conjunction"
				return @conjunctions.next
			else
				@last_word = "and"
				@curr_syllable = curr_syllable + 1
				return Word.new("and", ["AH0 N D"])
			end
		elsif decider == 2 then
			return prepositional_phrase()
		else
			@last_word = "punctuation"
			return "#{["?", "!", "."].sample}"
		end
	end

	def follow_adverb
		decider = rand(4)
		if decider == 0 then
			@last_word = "adverb"
			return @adverbs.next
		elsif decider == 1 then
			@last_word = "conjunction"
			return @conjunctions.next
		else
			@last_word = "punctuation"
			return "#{["?", "!", "."].sample}"
		end
	end
	
	def follow_conjunction
		if @complete_clause == false then
			# compound subject
			@plural = true
			return start_subject
		elsif @last_word == "and" then
			# compound predicate
			@complete_clause = true
			@last_word = "verb"
			if @plural == true then
				return @verbs.next
			else
				return make_present_tense(@verbs.next)
			end
		else
			# make a compound sentence, start a new clause
			@complete_clause = false
			@plural = false
			return start_subject
		end
	end

	def make_present_tense(verb)
		if verb.spelling.end_with?("s") or verb.spelling.end_with?("h")
			new_verb = @dict_reader.single_word(verb.spelling + "es")
		else 
			new_verb = @dict_reader.single_word(verb.spelling + "s")
		end

		while new_verb.pronunciations.empty?
			if verb.spelling.end_with?("s") or verb.spelling.end_with?("h")
				new_verb = @dict_reader.single_word(verb.spelling + "es")
			else 
				new_verb = @dict_reader.single_word(verb.spelling + "s")
			end
		end

		return new_verb
	end

	def phrase_to_word(phrase)
		# For turning a prepositional phrase--a list of Words--
		# into a single Word of its own.
		spelling = ""
		pronunciations = Array.new

		for word in phrase  # example: ["in", "his", "hat"]
			spelling += " " + word.spelling  # first "in", then "in his"...
			if pronunciations.empty?  # on "in"
				pronunciations = word.pronunciations
			else
				# this part runs in exponential time :/
				for pron1 in pronunciations  # "in", "een" (or whatever)
					new_prons = Array.new
					for pron2 in word.pronunciations  # "his", "heyes"
						new_prons << pron1 + " " + pron2
					end
					# new_prons is now all the potential combinations of ways
					# to pronounce this prepositional phrase. TODO: this might
					# get dicey later where words are expected to only have
					# a few pronunciations--prepositional phrases can have an
					# arbitrarily long number of adjectives and thus can be
					# potentially infinitely long.
					pronunciations = new_prons
				end
			end
		end

		return Word.new(spelling, pronunciations)
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
			end
		end
		return false
	end

	def rhymes?(word)
		if @rhyming_with == nil
			return true
		else
			if rhymes_with?(word, @rhyming_with)
				return true
			end
		end
		return false
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

	# def select_from(list)
	# 	curr_word = list.sample
	# 	while !scans?(curr_word)
	# 		curr_word = list.sample
	# 	end
	# 	return curr_word.spelling
	# end

	def get_nouns
		return @nouns
	end

	def get_verbs
		return @verbs
	end

end