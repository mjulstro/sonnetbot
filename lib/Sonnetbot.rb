require_relative 'verbs.rb'
require_relative 'adjectives.rb'
require_relative 'adverbs.rb'
require_relative 'nouns.rb'
require_relative 'conjunctions.rb'
require_relative 'prepositions.rb'
require_relative 'Word.rb'
require_relative 'Part_of_Speech.rb'
require_relative 'DictReader.rb'
require_relative 'Marker.rb'

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
		# poetic state variables
		@sonnet = Array.new
		@curr_line = 0
		@curr_syllable = 0
		@rhyming_with = nil
		@meter = "x/x/x/x/x/"
		@rhyme_scheme = "ABABCDCDEFEFGG"
		@rhyme_dict = Hash.new

		# keep adding sentences to the sonnet
		# until we reach the last syllable of the last line
		while @curr_line <= num_lines and @curr_syllable < meter.length
			@sonnet.concat(make(method(:sentence)))
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
			elsif word == "\n"
				if ["?", "!", ".", ","].include?(array[ind + 1])
					text << array[ind + 1]
					skip_next = true
				end
				text << "\n"
			elsif word.is_a?(Marker)
				next
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
		orig_word = word
		while !scans?(word) or !rhymes?(word)
			word = pos.next
			if word == orig_word
				array << nil
			end
		end

		@curr_syllable += @curr_add  # the length of the pronunciation that scanned for the last word
		array << word

		if @curr_syllable >= @meter.length
			@curr_syllable = 0
			@curr_line += 1
			array << "\n"
			# update_rhymes(word)

			while !scans?(word) or !rhymes?(word)
				word = pos.next
				if word == orig_word
					array << nil
				end
			end
		end

		return array
	end

	def update_rhymes(word)
		letter = @rhyme_scheme[@curr_line]

		if @rhyme_dict.include?(letter)
			@rhyming_with = @rhyme_dict[letter]
		else
			@rhyme_dict[letter] = word
			@rhyming_with = nil
		end
	end

	########## grammatical methods: for putting sentences together ##########

	def make(func, param = nil)
		for i in 0..5
			puts_all_state(func.name)
			if param == nil
				item = func.call
			else
				item = func.call(param)
			end

			if !item.include?(nil)
				if @curr_syllable >= @meter.length
					@curr_syllable = @curr_syllable - @meter.length
					@curr_line += 1
				end

				marker = Marker.new("#{func.name}", @curr_syllable, @curr_line)
				puts marker
				@sonnet << marker
				# sonnet.concat(item)
				return item
			else
				puts "THIS ARRAY HAD NIL IN IT:"
				puts item
				puts
				# THIS IS WHERE THE BACKTRACKING HAPPENS!
				# DELETE EVERYTHING AFTER THE LAST MARKER WITH GRAM_UNIT = FUNC.NAME
				del_point = @sonnet.rindex { |item| item.is_a?(Marker) and item.gram_unit == func.name}
				@sonnet.slice!(del_point + 1, -1)
				# RESET CURR_SYLLABLE AND CURR_LINE TO WHAT THEY WERE AT THAT LAST MARKER
				marker = @sonnet[del_point]
				@curr_syllable = marker.syl
				@curr_line = marker.line
				# DELETE THAT MARKER TOO
				@sonnet.pop
			end
		end
		return (Array.new) << nil
	end

	def sentence
		@sonnet << Marker.new("sentence", @curr_syllable, @curr_line)
		for pos in @pos_hash.values
			pos.shuffle
			pos.reset  # so we don't get the same words being chosen every time
		end

		# puts "Starting a sentence!"

		sentence = make(method(:clause))
		while rand(4) == 0
			in_progress = Array.new
			in_progress << ","
			in_progress.concat(choose(@conjunctions)).concat(make(method(:clause)))
			sentence.concat(in_progress)
			@sonnet.concat(in_progress)
		end

		punctuation = ["?", "!", "."].sample
		sentence << punctuation
		@sonnet << punctuation

		return sentence
	end

	def clause
		plural = false

		cls = Array.new
		while rand(6) == 0
			cls.concat(make(method(:prep_phrase)))
		end

		cls.concat(make(method(:subject)))
		while rand(4) == 0
			cls << " and"
			@curr_syllable += 1
			cls.concat(make(method(:subject)))
			plural = true
		end

		cls.concat(make(method(:predicate), plural))
		while rand(4) == 0
			cls << " and"
			@curr_syllable += 1
			cls.concat(make(method(:predicate), plural))
		end

		return cls
	end

	def subject
		subj = Array.new

		# "My"
		if rand(6) < 5
			pref = choose(@prefixes)
			subj.concat(pref)
			@sonnet.concat(pref)
		end

		# "My hungry, sweet"
		if rand(3) == 0
			adj = choose(@adjectives)
			subj.concat(adj)
			@sonnet.concat(adj)
			while rand(3) == 0
				adj = choose(@adjectives)
				(subj << ",").concat(adj)
				(@sonnet << ",").concat(adj)
			end
		end

		# "My hungry, sweet dog"
		noun = choose(@nouns)
		subj.concat(noun)
		@sonnet.concat(noun)

		# "My hungry, sweet dog with a green tail"
		while rand(4) == 0
			subj.concat(make(method(:prep_phrase)))
		end

		return subj
	end

	def predicate(plural)
		pred = Array.new

		# "snorts"
		verb = choose(@verbs)
		if plural
			pred.concat(verb)
			@sonnet.concat(verb)
		else
			pred.concat(make_present_tense(verb))
			@sonnet.concat(make_present_tense(verb))
		end

		# "snorts widely, sleepily, joyfully"
		adv = choose(@adverbs)
		if rand(4) == 0
			pred.concat(adv)
			@sonnet.concat(adv)
		end
		while rand(4) == 0
			(pred << ",").concat(adv)
			(@sonnet << ",").concat(adv)
		end

		# "snorts widely, sleepily, joyfully in a park"
		while rand(4) == 0
			pred.concat(make(method(:prep_phrase)))
		end

		return pred
	end

	def prep_phrase
		phrase = Array.new

		prep = choose(@prepositions)
		phrase.concat(prep)
		@sonnet.concat(prep)
		phrase.concat(make(method(:subject)))

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
		#TODO: determine @rhyming_with from @sonnet

		if @rhyming_with == nil or @curr_syllable + @curr_add < @meter.length or rhymes_with?(word, @rhyming_with)
			return true
		else
			return false
		end
	end

	def rhymes_with?(word1, word2)
		if !(last_syls(word1) & last_syls(word2)).empty?
			# if there's an overlap in the ways the two words' last syllables
			# can be pronounced
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

	def puts_all_state(input = nil)  # for debugging
		puts
		puts "*************DESCRIBING ENTIRE SONNETBOT STATE**************"
		puts "Line #{@curr_line}"
		puts @sonnet
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
