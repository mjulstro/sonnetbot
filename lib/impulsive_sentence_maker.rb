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
		sentence = start_sentence()

		while @last_word != "punctuation"
			sentence = follow(sentence)
		end

		return sentence
	end

	def follow(sentence)
		if @last_word == "noun" then
			sentence = follow_noun(sentence)
		elsif @last_word == "adjective" then
			sentence = follow_adjective(sentence)
		elsif @last_word == "prefix" then
			sentence = follow_prefix(sentence)
		elsif @last_word == "verb" then
			sentence = follow_verb(sentence)
		elsif @last_word == "adverb" then
			sentence = follow_adverb(sentence)
		elsif @last_word == "conjunction" then
			sentence = follow_conjunction(sentence)
		elsif @last_word == "preposition" then
			sentence = sentence + " " + start_sentence
		else
			sentence = "157-17348914587-Error!"
		end

		return sentence
	end

	def start_sentence
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

	def follow_prefix(prev)
		decider = rand(4)
		if decider == 0 then
			@last_word = "adjective"
			return prev + " #{@adjectives.sample}"
		else
			@last_word = "noun"
			return prev + " #{@nouns.sample}"
		end
	end

	def follow_adjective(prev)
		decider = rand(4)
		if decider == 0 then
			@last_word = "adjective"
			return prev + ", #{@adjectives.sample}"
		else
			@last_word = "noun"
			return prev + " #{@nouns.sample}"
		end
	end

	def follow_noun(prev)
		decider = rand(4)
		if decider == 0 then
			@last_word = "conjunction"
			return prev + " #{@conjunctions.sample}"
		elsif decider == 1 then
			@last_word = "preposition"
			return prev + " #{@prepositions.sample}"
		else
			@last_word = "verb"
			@complete_clause = true
			if @plural == true then
				return prev + " #{@verbs.sample}"
			else
				return prev + " #{make_present_tense(@verbs.sample)}"
			end
		end
	end

	def follow_verb(prev)
		decider = rand(4)
		if decider == 0 then
			@last_word = "adverb"
			return prev + " #{@adverbs.sample}"
		elsif decider == 1 then
			@last_word = "conjunction"
			return prev + ", #{@conjunctions.sample}"
		elsif decider == 2 then
			@last_word = "preposition"
			return prev + " #{@prepositions.sample}"
		else
			@last_word = "punctuation"
			return prev.capitalize + "#{["?", "!", "."].sample}"
		end
	end

	def follow_adverb(prev)
		decider = rand(4)
		if decider == 0 then
			@last_word = "adverb"
			return prev + ", #{@adverbs.sample}"
		elsif decider == 1 then
			@last_word = "conjunction"
			return prev + ", #{@conjunctions.sample}"
		else
			@last_word = "punctuation"
			return prev.capitalize + "#{["?", "!", "."].sample}"
		end
	end
	
	def follow_conjunction(prev)
		if @complete_clause == false then
			if prev.end_with?("and") then
				@plural = true
			end
			return prev + " " + start_sentence
		else
			decider = rand(2)
			if decider == 0 then
				@last_word = "verb"
				if @plural == true then
					return prev + " #{@verbs.sample}"
				else
					return prev + " " + make_present_tense(@verbs.sample)
				end
			else
				@complete_clause = false
				@plural = false
				return prev + " " + start_sentence
			end
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