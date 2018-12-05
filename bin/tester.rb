require_relative '../lib/Sonnetbot.rb'
require_relative '../lib/DictReader.rb'

sonnetbot = Sonnetbot.new

def write_ten_sentences
	for i in 1..10
		puts sonnetbot.make_sentence
	end
end

# TODO: update this for the new hybrid Word class
# (to_s overridden, contains constructor and find_stress_pattern)
def test_word_creation(spelling)
	dict_reader = DictReader.new
	word = dict_reader.make_single_word(spelling)
	puts word.get_spelling
	puts word.get_pronunciations
	puts word.get_stress_patterns
	puts word.get_nums_syllables
	puts ""
end

# puts sonnetbot.make_sentence()