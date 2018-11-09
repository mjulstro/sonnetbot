require_relative '../lib/Sonnetbot.rb'
require_relative '../lib/DictReader.rb'

sonnetbot = Sonnetbot.new
dict_reader = DictReader.new

# for i in 1..10
# 	puts sonnetbot.make_sonnet
# end

beneath = dict_reader.make_single_word("beneath")
puts beneath.get_spelling
puts beneath.get_pronunciations
puts beneath.get_stress_patterns
puts beneath.get_nums_syllables
puts ""
puts sonnetbot.scans?(beneath)