require_relative '../lib/Sonnetbot.rb'
require_relative '../lib/DictReader.rb'

# sonnetbot = Sonnetbot.new

def test_rhymes
	sonnetbot = Sonnetbot.new
	# these should print true-false-true-true
	# TODO: turn this into a real unit test and make these asserts
	puts sonnetbot.rhymes_with?(Word.new("beneath", ["B IH0 N IY1 TH"]), Word.new("bequeath", ["B IH0 K W IY1 TH"]))
	puts sonnetbot.rhymes_with?(Word.new("harmful", ["HH AA1 R M F AH0 L"]), Word.new("bequeath", ["B IH0 K W IY1 TH"]))
	puts sonnetbot.rhymes_with?(Word.new("harmful", ["HH AA1 R M F AH0 L"]), Word.new("hateful", ["HH EY1 T F AH0 L"]))
	puts sonnetbot.rhymes_with?(Word.new("roadblock", ["R OW1 D B L AA2 K"]), Word.new("roadblock", ["R OW1 D B L AA2 K"]))
end

def test_scansion
	sonnetbot = Sonnetbot.new
	# these should print true-false-true-true
	# TODO: turn this into a real unit test and make these asserts
	puts sonnetbot.scans?(Word.new("he", ["HH IY1"]))
	puts sonnetbot.scans?(Word.new("compliments", ["K AA1 M P L AH0 M EH0 N T S"]))
	puts sonnetbot.scans?(Word.new("complete", ["K AH0 M P L IY1 T"]))
	puts sonnetbot.scans?(Word.new("compound", ["K AA1 M P AW0 N D", "K AH0 M P AW1 N D"]))
end

sonnetbot = Sonnetbot.new
puts sonnetbot.make_sonnet()