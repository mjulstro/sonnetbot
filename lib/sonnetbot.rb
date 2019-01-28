require_relative 'verbs.rb'
require_relative 'adjectives.rb'
require_relative 'adverbs.rb'
require_relative 'nouns.rb'
require_relative 'conjunctions.rb'
require_relative 'prepositions.rb'
require_relative 'word.rb'
require_relative 'part_of_speech.rb'
require_relative 'dict_reader.rb'

class Sonnetbot
  def initialize
    @dict_reader = DictReader.new
    # vocabulary
    prefixes = %w[a the my your his her their our]
    @pos_hash = @dict_reader.initialize_lists(prefixes,
                                              fill_adjectives, fill_nouns,
                                              fill_verbs, fill_adverbs,
                                              fill_conjunctions,
                                              fill_prepositions)
    @prefixes     = @pos_hash['prefixes']
    @adjectives   = @pos_hash['adjectives']
    @nouns        = @pos_hash['nouns']
    @verbs        = @pos_hash['verbs']
    @adverbs      = @pos_hash['adverbs']
    @conjunctions = @pos_hash['conjunctions']
    @prepositions = @pos_hash['prepositions']
  end

  ########## primary methods: the meat and bones ##########

  def make_sonnet(num_lines = 14, meter = 'x/x/x/x/x/', rhyme_scheme = 'ABABCDCDEFEFGG')
    @curr_line = 0
    @curr_syllable = 0
    @rhyming_with = nil
    @meter = meter
    @rhyme_scheme = rhyme_scheme
    @rhyme_dict = {}
    @num_lines = num_lines

    @sonnet = []

    # keep adding sentences to the sonnet
    # until we reach the last syllable of the last line
    while (@curr_line <= @num_lines) && (@curr_syllable <= meter.length)
      @sonnet.concat sentence
    end

    to_text @sonnet
  end

  # def make_sentence
  #   return sentence_to_text(sentence)
  # end

  def to_text(array)
    text = ''
    capital = true
    ind = 0
    skip_next = false
    array.each do |word|
      if %w[? ! .].include? word
        text << word unless skip_next
        skip_next = false
        capital = true
      elsif [',', ' and'].include? word
        text << word unless skip_next
        skip_next = false
        capital = false
      elsif (word == 'NEWLINE') || (word == "\n")
        if %w[? ! . ,].include?(array[ind + 1])
          text << array[ind + 1]
          skip_next = true
        end
        text << "\n"
      else
        text << ' ' << if capital
                         word.spelling.capitalize
                       else
                         word.spelling
                       end
        capital = false
      end
      ind += 1
    end

    text
  end

  def choose(pos)
    array = []

    word = pos.next
    orig = word
    while !scans?(word) || !rhymes?(word)
      word = pos.next
      next unless word == orig

      # we went through the entire part-of-speech list without finding
      # a word that both scans and rhymes
      array << nil
      break
    end

    @curr_syllable += @curr_add # the length of the pronunciation that scanned for the last word
    array << word

    # puts "#{@curr_line}:#{@curr_syllable} #{word.spelling}
    if @curr_syllable >= @meter.length
      update_rhymes word
      @curr_syllable = 0
      @curr_line += 1
      array << 'NEWLINE'
      # puts array

      orig = word
      while !scans?(word) || !rhymes?(word)
        word = pos.next
        if word == orig
          array << nil
          break
        end
      end
    end

    array
  end

  def update_rhymes(word)
    # assign this word to be the rhyme for this letter
    letter = @rhyme_scheme[@curr_line]
    @rhyme_dict[letter] = word if !letter.nil? && !@rhyme_dict.include?(letter)

    # assign @rhyming_with according to the next line in the rhyme scheme
    letter2 = @rhyme_scheme[@curr_line + 1]
    @rhyming_with = @rhyme_dict[letter2] if !letter2.nil? && @rhyme_dict.include?(letter2)

    # begin
    #   # puts "*******************#{@curr_line + 1}, #{letter2}, #{@rhyming_with.spelling}, #{@rhyme_dict[letter2].spelling}"
    # rescue
    #   # if @rhyming_with or @rhyme_dict[letter] is nil
    #   # puts "*******************#{@curr_line + 1}, #{letter2}"
    # end
  end

  ########## grammatical methods: for putting sentences together ##########

  def sentence
    syl = @curr_syllable
    line = @curr_line
    6.times do
      @pos_hash.values.each do |pos|
        pos.shuffle
        pos.reset # so we don't get the same words being chosen every time
      end

      # puts "Starting a sentence!"

      sentence = clause
      while rand(4).zero? && (@curr_line < @num_lines)
        (sentence << ',').concat(choose(@conjunctions)).concat(clause)
      end

      sentence << %w[? ! .].sample
      return sentence unless sentence.include? nil

      @curr_syllable = syl
      @curr_line = line
    end
  end

  def clause
    line = @curr_line
    syl = @curr_syllable
    6.times do
      plural = false
      clause = []

      clause.concat prep_phrase while rand(4).zero? && (@curr_line < @num_lines)

      clause.concat subject
      while rand(4).zero? && (@curr_line < @num_lines)
        clause << ' and'
        @curr_syllable += 1
        clause.concat subject
        plural = true
      end

      clause.concat predicate plural
      while rand(4).zero? && (@curr_line < @num_lines)
        clause << ' and'
        @curr_syllable += 1
        clause.concat predicate plural
      end

      return clause unless clause.include? nil

      @curr_line = line
      @curr_syllable = syl
    end
    [] << nil
  end

  def subject
    line = @curr_line
    syl = @curr_syllable
    6.times do
      subj = []

      # "My"
      subj.concat choose @prefixes if rand(6) < 5

      # "My hungry, sweet"
      if rand(2).zero?
        subj.concat choose @adjectives
        (subj << ',').concat choose @adjectives while rand(2).zero?
      end

      # "My hungry, sweet dog"
      subj.concat choose @nouns

      # "My hungry, sweet dog with a green tail"
      subj.concat prep_phrase while rand(4).zero? && (@curr_line < @num_lines)

      return subj unless subj.include? nil

      @curr_line = line
      @curr_syllable = syl
    end
    [] << nil
  end

  # @param [Object] plural
  # @return [Object]
  def predicate(plural)
    line = @curr_line
    syl = @curr_syllable
    return [] << nil if choose(@verbs).include? nil

    6.times do
      pred = []

      # "snorts"
      if plural
        pred.concat choose @verbs
      else
        # TODO: The commented-out part below is not
        # adapted to the fact that "choose" returns
        # an Array. Deal with this... someday

        # # this section is to protect against choosing a verb for its
        # # non-conjugated form, and then conjugating it and having it
        # # not scan or rhyme anymore
        # chosen = make_present_tense(choose(@verbs))
        # while !scans?(chosen) or !rhymes?(chosen)
        #   chosen = make_present_tense(choose(@verbs))
        # end
        # pred.concat(chosen)
        pred.concat make_present_tense choose @verbs
      end

      # "snorts widely, sleepily, joyfully"
      if rand(4).zero?
        pred.concat choose @adverbs
        (pred << ',').concat choose @adverbs while rand(4).zero?

      end

      # "snorts widely, sleepily, joyfully in a park"
      pred.concat prep_phrase while rand(4).zero? && (@curr_line < @num_lines)

      return pred unless pred.include? nil

      @curr_line = line
      @curr_syllable = syl
    end
    [] << nil
  end

  def prep_phrase
    syl = @curr_syllable
    line = @curr_line
    6.times do
      phrase = []

      phrase.concat choose @prepositions
      phrase.concat subject

      return phrase unless phrase.include? nil

      @curr_line = line
      @curr_syllable = syl
    end
    [] << nil
  end

  def make_present_tense(array)
    verb = array[0]
    unless verb.nil?
      new_verb = if verb.spelling.end_with? 's', 'h'
                   @dict_reader.single_word(verb.spelling + 'es')
                 else
                   @dict_reader.single_word(verb.spelling + 's')
                 end

      array[0] = new_verb
    end
    array
  end

  ########## poetic methods: for choosing the right words ##########

  # @param [Object] word
  # @return [Boolean]
  def scans?(word)
    word.stress_patterns.each do |stress_pattern|
      correct_stress = @meter.slice(@curr_syllable, stress_pattern.length)
      if (stress_pattern == correct_stress) && (@curr_syllable + stress_pattern.length <= @meter.length)
        # if this word is chosen for the poem, this is how many
        # syllables we'll advance in the line
        @curr_add = stress_pattern.length
        return true
      elsif (@curr_syllable < @meter.length) && (stress_pattern.length == 1)
        @curr_add = stress_pattern.length
        return true
      end
    end
    false
  end

  def rhymes?(word)
    if @rhyming_with.nil? || ((@curr_syllable + @curr_add) < @meter.length)
      true
    elsif rhymes_with? word, @rhyming_with
      true
    else
      false
    end
  end

  def rhymes_with?(word1, word2)
    if !(last_syls(word1) & last_syls(word2)).empty?
      # if there's an overlap in the ways the two words can be pronounced
      true
    else
      false
    end
  end

  # @param [Object] word
  # @return [Array] last_syls
  def last_syls(word)
    # puts_all_state(word.spelling)
    last_syls = []
    ind = 0
    word.pronunciations.each do |pronunciation|
      ind += 1
      begin
        # pron_length = word.stress_patterns[word.pronunciations.index pronunciation].length
        # if @curr_syllable + pron_length <= @meter.length - 1
        #   return true
        #   # return true if this word doesn't put us at the end of the line
        # end

        last_syl_start = pronunciation.rindex(/\d/) - 2
        last_syl = pronunciation.slice last_syl_start..pronunciation.length
        last_syl = last_syl.tr('012', '') # removes stress information; this should be accounted for by the scansion
        last_syls << last_syl
      rescue StandardError
        # usually an error will be thrown if the pronunciations list is too long for
        # some reason. In this case, the pronunciations list should be shortened.
        word.shorten_prons ind
      end
    end
    last_syls
  end

  # for debugging
  def puts_all_state(input = nil)
    puts
    puts '*************DESCRIBING ENTIRE SONNETBOT STATE**************'
    puts "Line #{@curr_line}"
    puts "Syllable #{@curr_syllable}"
    if @rhyming_with.nil?
      puts 'Rhyming with nil'
    else
      puts "Rhyming with #{@rhyming_with.spelling}"
    end

    puts input unless input.nil?
  end
end