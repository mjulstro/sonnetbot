require_relative '../lib/impulsive_sentence_maker.rb'

speaker = ImpulsiveSentenceMaker.new

for i in 1..10
	puts speaker.make_sentence
end