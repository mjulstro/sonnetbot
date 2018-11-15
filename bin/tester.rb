require_relative '../lib/Sonnetbot.rb'
require_relative '../lib/DictReader.rb'

sonnetbot = Sonnetbot.new
dict_reader = DictReader.new

# for i in 1..10
# 	puts sonnetbot.make_sonnet
# end

puts sonnetbot.make_sentence

# beneath = dict_reader.make_single_word("beneath")
# puts beneath
# puts sonnetbot.rhymes?(beneath)