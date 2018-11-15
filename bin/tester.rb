require_relative '../lib/Sonnetbot.rb'
require_relative '../lib/DictReader.rb'

sonnetbot = Sonnetbot.new

# def write_one_sonnet
# 	puts sonnetbot.make_sonnet()
# end

# def write_one_sentence
# 	puts sonnetbot.make_sentence
# end

def write_ten_sentences
	for i in 1..10
		puts sonnetbot.make_sentence
	end
end

def test_word_creation(spelling)
	dict_reader = DictReader.new
	word = dict_reader.make_single_word(spelling)
	puts word.get_spelling
	puts word.get_pronunciations
	puts word.get_stress_patterns
	puts word.get_nums_syllables
	puts ""
end

def test_scansion_evaluation(word)
	puts sonnetbot.rhymes?(word)
end

def test_rhyme_evaluation(word)
	puts sonnetbot.rhymes?(beneath)
end

puts sonnetbot.make_sentence()