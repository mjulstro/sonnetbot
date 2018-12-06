require_relative 'verbs.rb'
require_relative 'adjectives.rb'
require_relative 'adverbs.rb'
require_relative 'nouns.rb'
require_relative 'conjunctions.rb'
require_relative 'prepositions.rb'
require_relative 'Word.rb'
require_relative 'DictReader.rb'

class Sonnetbot

	def initialize
		dict_reader = DictReader.new
		# vocabulary
		prefixes = ["a", "the", "my", "your", "his", "her", "their", "our"]
		hash_of_lists = dict_reader.initialize_lists(prefixes,
			fill_adjectives, fill_nouns, fill_verbs, fill_adverbs,
			fill_conjunctions, fill_prepositions)
		@prefixes     = hash_of_lists["prefixes"]
		@adjectives   = hash_of_lists["adjectives"]
		@nouns        = hash_of_lists["nouns"]
		@verbs        = hash_of_lists["verbs"]
		@adverbs      = hash_of_lists["adverbs"]
		@conjunctions = hash_of_lists["conjunctions"]
		@prepositions = hash_of_lists["prepositions"]

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
		while !(@curr_line == num_lines and @curr_syllable == meter.length)
			sonnet = sonnet + " " + make_sentence
		end

		return sonnet
	end

	def make_sentence
		puts "Starting a sentence!"
		@complete_clause = false
		@plural = false
		sentence = start_predicate()

		while @last_word != "punctuation"
			puts sentence
			next_word = follow(sentence)
			while !scans?(next_word) or !rhymes?(next_word)
				next_word = follow(setence)
			end
			sentence = sentence + next_word

			if @curr_syllable == @meter.length
				sentence + sentence + "\n"
				@curr_syllable = 0
				@curr_line = curr_line + 1
			end
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
			return select_from(@nouns)
		elsif decider == 1 then
			@last_word = "adjective"
			return select_from(@adjectives)
		else
			@last_word = "prefix"
			return select_from(@prefixes)
		end
	end

	def prepositional_phrase
		phrase = select_from(@prepositions)
		phrase = phrase + " " + start_predicate()

		while @last_word != "noun" do
			phrase = phrase + " " + follow(phrase)
		end
		return phrase
	end

	def follow_prefix
		decider = rand(4)
		if decider == 0 then
			@last_word = "adjective"
			return select_from(@adjectives)
		else
			@last_word = "noun"
			return select_from(@nouns)
		end
	end

	def follow_adjective
		decider = rand(4)
		if decider == 0 then
			@last_word = "adjective"
			return ", " + select_from(@adjectives)
		else
			@last_word = "noun"
			return "  " + select_from(@nouns)
		end
	end

	def follow_noun
		decider = rand(4)
		if decider == 0 then
			if @complete_clause == true
				@last_word = "conjunction"
				@complete_clause = false
				return select_from(@conjunctions)
			else
				@last_word = "and"
				@curr_syllable = curr_syllable + 1
				return "and"
			end
		elsif decider == 1 then
			return prepositional_phrase
		else
			@last_word = "verb"
			@complete_clause = true
			if @plural == true then
				return select_from(@verbs)
			else
				return make_present_tense(select_from(@verbs))
			end
		end
	end

	def follow_verb
		decider = rand(4)
		if decider == 0 then
			@last_word = "adverb"
			return " #{select_from(@adverbs)}"
		elsif decider == 1 then
			decider2 = rand(4)
			if decider2 == 0
				@last_word = "conjunction"
				return ", #{select_from(@conjunctions)}"
			else
				@last_word = "and"
				@curr_syllable = curr_syllable + 1
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
			return ", #{select_from(@adverbs)}"
		elsif decider == 1 then
			@last_word = "conjunction"
			return ", #{select_from(@conjunctions)}"
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
				return select_from(@verbs)
			else
				return make_present_tense(select_from(@verbs))
			end
		else
			# make a compound sentence, start a new clause
			@complete_clause = false
			@plural = false
			return start_predicate
		end
	end

	def make_present_tense(verb)
		if verb.get_spelling.end_with?("s") or verb.get_spelling.end_with?("h")
			return verb.get_spelling + "es"
		else 
			return verb.get_spelling + "s"
		end
	end


	########## poetic methods: for choosing the right words ##########

	def scans?(word)
		for stress_pattern in word.get_stress_patterns
			correct_stress = @meter.slice(@curr_syllable - 1, stress_pattern.length)
			# puts stress_pattern
			# puts correct_stress
			if stress_pattern == correct_stress and @curr_syllable + stress_pattern.length <= @meter.length
				@curr_syllable = @curr_syllable + stress_pattern.length
				return true
			end
		end
		return false
	end

	def rhymes?(word1, word2)
		if !(last_syls(word1) & last_syls(word2)).empty?
			# if there's an overlap in the ways the two words can be pronounced
			return true
		else
			return false
		end
	end

	def last_syls(word)
		last_syls = Array.new
		for pronunciation in word.get_pronunciations
			pron_length = word.stress_patterns[word.get_pronunciations.indexOf(pronunciation)].length
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

	def select_from(list)
		curr_word = list.sample
		while !scans?(curr_word)
			curr_word = list.sample
		end
		return curr_word.spelling
	end

	def get_nouns
		return @nouns
	end

	def get_verbs
		return @verbs
	end

end