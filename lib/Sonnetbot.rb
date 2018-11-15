require_relative 'verbs.rb'
require_relative 'adjectives.rb'
require_relative 'adverbs.rb'
require_relative 'nouns.rb'
require_relative 'conjunctions.rb'
require_relative 'prepositions.rb'

class Sonnetbot

	def initialize

		# part-of-speech lists
		@prefixes = ["a", "the", "my", "your", "his", "her", "their", "our"]
		@adjectives = fill_adjectives
		@nouns = fill_nouns
		@verbs = fill_verbs
		@adverbs = fill_adverbs
		@conjunctions = fill_conjunctions
		@prepositions = fill_prepositions

		# grammatical state variables
		@last_word = ""
		@complete_clause = false
		@plural = false

		# poetic state variables
		@curr_line = 1
		@curr_syllable = 1
		@rhyming_with = nil
		@meter = "x/x/x/x/x/"
		@rhyme_scheme = nil
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
		while !(@curr_line == num_lines and @curr_syllable == meter.length)
			sonnet = sonnet + " " + make_sentence
		end

		return sonnet
	end

	def make_sentence
		@complete_clause = false
		@plural = false
		sentence = start_predicate()

		while @last_word != "punctuation"
			next_word = follow(sentence)
			# while !scans?(next_word)
			# 	next_word = follow(sentence)
			# end
			sentence += next_word
		end

		return sentence.capitalize
	end

	def follow(sentence)
		case @last_word
		when "noun"
			return " " + follow_noun
		when "adjective"
			return follow_adjective
		when "prefix"
			return " " + follow_prefix
		when "verb"
			return follow_verb
		when "adverb"
			return follow_adverb
		when "conjunction", "and"
			return " " + follow_conjunction
		else
			return "Error!"
		end
	end


	########## grammatical methods: for putting sentences together ##########

	def start_predicate
		decider = rand(6)
		if decider == 0 then
			@last_word = "noun"
			return @nouns.sample
		elsif decider == 1 then
			@last_word = "adjective"
			return @adjectives.sample
		else
			@last_word = "prefix"
			return @prefixes.sample
		end
	end

	def prepositional_phrase
		phrase = @prepositions.sample + " " + start_predicate()
		while @last_word != "noun" do
			phrase = follow(phrase)
		end
		return phrase
	end

	def follow_prefix
		decider = rand(4)
		if decider == 0 then
			@last_word = "adjective"
			return @adjectives.sample
		else
			@last_word = "noun"
			return @nouns.sample
		end
	end

	def follow_adjective
		decider = rand(4)
		if decider == 0 then
			@last_word = "adjective"
			return ", #{@adjectives.sample}"
		else
			@last_word = "noun"
			return " #{@nouns.sample}"
		end
	end

	def follow_noun
		decider = rand(4)
		if decider == 0 then
			if @complete_clause == true
				@last_word = "conjunction"
				@complete_clause = false
				return @conjunctions.sample
			else
				@last_word = "and"
				return "and"
			end
		elsif decider == 1 then
			return prepositional_phrase
		else
			@last_word = "verb"
			@complete_clause = true
			if @plural == true then
				return @verbs.sample
			else
				return make_present_tense(@verbs.sample)
			end
		end
	end

	def follow_verb
		decider = rand(4)
		if decider == 0 then
			@last_word = "adverb"
			return " #{@adverbs.sample}"
		elsif decider == 1 then
			decider2 = rand(4)
			if decider2 == 0
				@last_word = "conjunction"
				return ", #{@conjunctions.sample}"
			else
				@last_word = "and"
				return " and"
			end
		elsif decider == 2 then
			return " " + prepositional_phrase()
		else
			@last_word = "punctuation"
			return "#{["?", "!", "."].sample}"
		end
	end

	def follow_adverb
		decider = rand(4)
		if decider == 0 then
			@last_word = "adverb"
			return ", #{@adverbs.sample}"
		elsif decider == 1 then
			@last_word = "conjunction"
			return ", #{@conjunctions.sample}"
		else
			@last_word = "punctuation"
			return "#{["?", "!", "."].sample}"
		end
	end
	
	def follow_conjunction
		if @complete_clause == false then
			# compound subject
			@plural = true
			return start_predicate
		elsif @last_word == "and" then
			# compound predicate
			@complete_clause = true
			@last_word = "verb"
			if @plural == true then
				return @verbs.sample
			else
				return make_present_tense(@verbs.sample)
			end
		else
			# make a compound sentence, start a new clause
			@complete_clause = false
			@plural = false
			return start_predicate
		end
	end

	def make_present_tense(verb)
		if verb.end_with?("s") or verb.end_with?("h") then
			verb = "#{verb}es"
		else 
			verb = "#{verb}s"
		end
	end


	########## poetic methods: for choosing the right words ##########

	def scans?(word)
		for stress_pattern in word.get_stress_patterns
			correct_stress = @meter.slice(@curr_syllable - 1, stress_pattern.length)
			# puts stress_pattern
			# puts correct_stress
			if stress_pattern == correct_stress and @curr_syllable + stress_pattern.length <= @meter.length
				return true
			end
		end
		return false
	end

	def rhymes?(word)
		# This is O(n), which is a lot to do for every word, but
		# very few words have more than 2 or 3 pronunciations,
		# so it's almost constant time.

		# example pronunciation strings: "AE1 D M ER0 AH0 B AH0 L"
		# "L AE1 N D R OW1 V ER0"
		# "R OW2 HH AY1 P N AO2 L"
		# example @rhyming_with: "AH1 L"
		for pronunciation in word.get_pronunciations
			last_syl_start = pronunciation.rindex(/\d/) - 2
			last_syl = pronunciation.slice(last_syl_start..pronunciation.length)
			last_syl = last_syl.tr('012', '')  # removes stress information; this should be accounted for by the scansion
			if @rhyming_with == last_syl
				return true
			end
		end
		return false
	end

end