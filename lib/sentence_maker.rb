require_relative 'verbs.rb'
require_relative 'adjectives.rb'
require_relative 'adverbs.rb'
require_relative 'nouns.rb'
require_relative 'conjunctions.rb'
require_relative 'prepositions.rb'

class SentenceMaker

	def initialize
		@prefixes = ["a", "the", "my", "your", "his", "her", "their", "our"]
		@adj = fill_adjectives
		@nouns = fill_nouns
		@v = fill_verbs
		@adverbs = fill_adverbs
		@conj = fill_conjunctions
		@prepositions = fill_prepositions
	end

	def make_sentence
		punctuate(configure_sentence)
	end

	def configure_sentence
		decider = rand(6)
		if decider == 1 then
			sentence = configure_sentence + ", #{@conj.sample} " + configure_sentence
		elsif decider == 2 then
			sentence = configure_sentence + "; " + configure_sentence
		else
			sentence = make_clause
		end
		return sentence
	end

	def make_clause
		@plural = false
		subj = make_compound_subject(@adj, @nouns, @prefixes)
		pred = make_compound_predicate(@adverbs, @v)
		return "#{subj} #{pred}"
	end

	def punctuate(sentence)
		sentence = sentence.chomp(" ").capitalize
		decider = rand(5)
		if decider == 1 then
			sentence = sentence + "?"
		elsif decider == 2 then
			sentence = sentence + "!"
		else
			sentence = sentence + "."
		end
		return sentence
	end

	def make_subject(adjectives, nouns, prefixes)
		decider = rand(4)
		if decider == 1 then
			subject = choose_adjectives(adjectives) + " #{nouns.sample}"
		else
			subject = "#{nouns.sample}"
		end

		decider = rand(10)
		if subject == "you" then
			#do nothing
		elsif decider != 1 then
			prefix = prefixes.sample
			if prefix == "a" and subject.start_with?("a", "e", "i", "o", "u") then
				subject = "an " + subject
			else
				subject = "#{prefix} " + subject
			end
		end

		subject = subject + make_prepositional_phrases
		return subject
	end

	def make_prepositional_phrases
		decider = rand(4)
		if decider == 1 then
			prep = make_prepositional_phrases + "" + make_prepositional_phrases
		elsif decider == 2
			prep = " #{@prepositions.sample} " + make_subject(@adj, @nouns, @prefixes)
		else
			prep = ""
		end
		return prep
	end

	def make_predicate(adverbs, verbs)
		if @plural == false then
			v = make_present_tense(verbs.sample)
		else
			v = verbs.sample
		end

		decider = rand(4)
		if decider == 1 then
			predicate = "#{v}" + choose_adverbs(adverbs)
		else
			predicate = "#{v}"
		end
		return predicate + make_prepositional_phrases
	end

	def make_present_tense(verb)
		if verb.end_with?("s") or verb.end_with?("h") then
			verb = "#{verb}es"
		else 
			verb = "#{verb}s"
		end
	end

	def make_compound_subject(adjectives, nouns, prefixes)
		decider = rand(4)
		if decider == 1 then
			subject = make_compound_subject(adjectives, nouns, prefixes) + " and " + make_compound_subject(adjectives, nouns, prefixes)
			@plural = true
		else
			subject = make_subject(adjectives, nouns, prefixes)
		end
		return subject
	end

	def make_compound_predicate(adverbs, verbs)
		decider = rand(4)
		if decider == 1 then
			predicate = make_compound_predicate(adverbs, verbs) + " and " + make_compound_predicate(adverbs, verbs)
		else
			predicate = make_predicate(adverbs, verbs)
		end

		return predicate
	end

	def choose_adjectives(adjectives)
		decider = rand(4)
		if decider == 1 then
			adj = choose_adjectives(adjectives) + ", " + choose_adjectives(adjectives)
		else
			adj = "#{adjectives.sample}"
		end
		return adj
	end

	def choose_adverbs(adverbs)
		decider = rand(4)
		if decider == 1 then
			adv = choose_adverbs(adverbs) + "," + choose_adverbs(adverbs)
		else
			adv = " #{adverbs.sample}"
		end
		return adv
	end

	def make_response(question)
		words = question.downcase.gsub(/[^a-z0-9\s]/, '').split(" ")
		pref = []
		adj = []
		nouns = []
		verbs = []
		adv = []
		conj = []
		prep = []

		words.each do |word|
			if @prefixes.include?(word) then
				pref.push(word)
			elsif @adj.include?(word) then
				adj.push(word)
			elsif @nouns.include?(word) then
				nouns.push(word)
			elsif @v.include?(word) then
				verbs.push(word)
			elsif @adverbs.include?(word) then
				adv.push(word)
			elsif @conj.include?(word) then
				conj.push(word)
			elsif @prepositions.include?(word) then
				prep.push(word)
			end
		end

		if pref.empty? then
			pref = @prefixes
		end
		if adj.empty? then
			adj = @adj
		end
		if nouns.empty? then
			nouns = @nouns
		end
		if verbs.empty? then
			verbs = @v
		end
		if adv.empty? then
			adv = @adverbs
		end
		if conj.empty? then
			conj = @conj
		end
		if prep.empty? then
			prep = @prepositions
		end

		return make_ask_sentence(pref, adj, nouns, verbs, adv, conj, prep)
	end

	def make_ask_sentence(pref, adj, nouns, verbs, adv, conj, prep)
		punctuate(configure_ask_sentence(pref, adj, nouns, verbs, adv, conj, prep))
	end

	def configure_ask_sentence(pref, adj, nouns, verbs, adv, conj, prep)
		decider = rand(12)
		if decider == 1 or decider == 2 then
			sentence = configure_ask_sentence(pref, adj, nouns, verbs, adv, conj, prep) + ", #{conj.sample} " + configure_ask_sentence(pref, adj, nouns, verbs, adv, conj, prep)
		elsif decider == 2 or decider == 3 then
			sentence = configure_ask_sentence(pref, adj, nouns, verbs, adv, conj, prep) + "; " + configure_ask_sentence(pref, adj, nouns, verbs, adv, conj, prep)
		elsif decider == 4 then
			sentence = configure_sentence
		else
			sentence = make_ask_clause(pref, adj, nouns, verbs, adv, conj, prep)
		end
		return sentence
	end

	def make_ask_clause(pref, adj, nouns, verbs, adv, conj, prep)
		@plural = false
		subj = make_compound_subject(adj, nouns, pref)
		pred = make_compound_predicate(adv, verbs)
		return "#{subj} #{pred}"
	end

end