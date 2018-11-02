require_relative '../lib/sentence_maker.rb'

speaker = SentenceMaker.new

def test_sentence_making
	for i in 1..10
		puts speaker.make_sentence
	end
end

def test_ask_answering
	for i in 1..10
		response = speaker.make_response("My girlfriend is so cute!")
		puts response
		puts speaker.make_response(response)
		puts ""
	end
end

#test_sentence_making
#test_ask_answering

input = gets
puts speaker.make_response(input)