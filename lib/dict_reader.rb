require_relative 'word.rb'
require_relative 'part_of_speech.rb'

class DictReader
  CMUDICT = 'C:\Users\meepi\Downloads\sonnetbot\lib\cmudict.txt'.freeze

  def initialize_lists(prefixes, adjectives, nouns, verbs, adverbs,
                       conjunctions, prepositions)
    @parts_of_speech = {}

    @parts_of_speech['prefixes']     = Part_of_Speech.new(prefixes,     'prefixes')
    @parts_of_speech['adjectives']   = Part_of_Speech.new(adjectives,   'adjectives')
    @parts_of_speech['nouns']        = Part_of_Speech.new(nouns,        'nouns')
    @parts_of_speech['verbs']        = Part_of_Speech.new(verbs,        'verbs')
    @parts_of_speech['adverbs']      = Part_of_Speech.new(adverbs,      'adverbs')
    @parts_of_speech['conjunctions'] = Part_of_Speech.new(conjunctions, 'conjunctions')
    @parts_of_speech['prepositions'] = Part_of_Speech.new(prepositions, 'prepositions')

    initialize_current_word_array # first time: @next_word = a
    curr_word = @next_word # curr_word = a
    initialize_current_word_array # @next_word = "abandoned"

    # iterate over the lines in the CMU Dict comparing them
    # to the word in the lists that's alphabetically first
    File.foreach(CMUDICT) do |line|
      if @next_word == 'zzzzzzzzzzzzz'
        word = Word.new(curr_word, @pronunciation_array)
        @curr_word_pos.add(word)
        break # we've gotten through all the words in the vocab

        # if there are multiple pronunciations in CMUdict
        # for the word, this will find all of them
      elsif line.start_with?(curr_word.upcase) && [' ', '('].include?(line[curr_word.length])
        # all the characters before the first " " in that
        # string comprise the word; everything else is the
        # pronunciation
        pronunciation = line.split(' ')[1..-1].join(' ')
        @pronunciation_array << pronunciation
      elsif line.start_with?(@next_word.upcase) && [' ', '('].include?(line[@next_word.length])
        word = Word.new(curr_word, @pronunciation_array)
        @curr_word_pos.add(word)
        curr_word = @next_word

        initialize_current_word_array

        pronunciation = line.split(' ')[1..-1].join(' ')
        @pronunciation_array << pronunciation
      else
        if line.split(' ')[0] > @next_word.upcase
          word = Word.new(curr_word, @pronunciation_array)
          @curr_word_pos.add(word)

          initialize_current_word_array
          curr_word = @next_word
          initialize_current_word_array
        end
      end
    end

    puts 'Done initializing the lists!'
    # useless_variable = gets
    @parts_of_speech
  end

  def single_word(word)
    pronunciation_array = []
    File.foreach(CMUDICT) do |line|
      if line.start_with?(word.upcase) && [' ', '('].include?(line[word.length])
        # all the characters before the first " " in that
        # string comprise the word; everything else is the
        # pronunciation
        pronunciation = line.split(' ')[1..-1].join(' ')
        pronunciation_array << pronunciation
      end
    end
    if pronunciation_array.empty?
      puts "#{word} could not be found in the CMUDict!"
    end
    Word.new(word, pronunciation_array)
  end

  def initialize_current_word_array
    @curr_word_pos = @next_word_pos
    @next_word = 'zzzzzzzzzzzzz'
    @parts_of_speech.values.each do |pos|
      next if pos.done?

      word_to_be_added = pos.first
      if word_to_be_added < @next_word
        @next_word = word_to_be_added
        @next_word_pos = pos
      end
    end
    # puts @next_word + "\t" + @next_word_pos.key
    @next_word_pos.increment
    @pronunciation_array = [] # this word's pronunciations
  end
end
