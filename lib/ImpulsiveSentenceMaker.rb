require_relative 'verbs.rb'
require_relative 'adjectives.rb'
require_relative 'adverbs.rb'
require_relative 'nouns.rb'
require_relative 'conjunctions.rb'
require_relative 'prepositions.rb'

class ImpulsiveSentenceMaker

	def initialize
		@prefixes = ["a", "the", "my", "your", "his", "her", "their", "our"]
		@adjectives = fill_adjectives
		@nouns = fill_nouns
		@verbs = fill_verbs
		@adverbs = fill_adverbs
		@conjunctions = fill_conjunctions
		@prepositions = fill_prepositions
		@last_word = ""
		@complete_clause = false
		@plural = false
	end

	def make_sentence
		@complete_clause = false
		@plural = false
		sentence = start_predicate()

		while @last_word != "punctuation"
			sentence = follow(sentence)
		end

		return sentence.capitalize
	end

	def follow(sentence)
		case @last_word
		when "noun"
			return sentence + " " + follow_noun
		when "adjective"
			return sentence + follow_adjective
		when "prefix"
			return sentence +" "+ follow_prefix
		when "verb"
			return sentence + follow_verb
		when "adverb"
			return sentence + follow_adverb
		when "conjunction", "and"
			return sentence + " " + follow_conjunction
		else
			return "Error!"
		end
	end

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

end