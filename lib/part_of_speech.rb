class PartOfSpeech

	def initialize(old_list, key)
		@key = key
		@old_list = old_list.sort_by { |word| word.downcase }
		@new_list = Array.new
		@index = 0
	end

	def key
		return @key
	end

	def increment
		@index += 1
	end

	def reset
		@index = 0
	end

	def add(word)
		@new_list << word
	end

	def first
		return @old_list[@index]
	end

	def next
		ret = @new_list[@index]
		@index += 1
		if @index >= @new_list.length
			@index = 0
		end
		return ret
	end

	def final
		return @new_list
	end

	def done?
		if @index >= @old_list.length
			return true
		else
			return false
		end
	end

	def shuffle
		@new_list = @new_list.shuffle
	end

	# def sort_by_distance(word)
	# 	# This will be implemented if I ever get around to using Word2Vec
	# 	# vector distances for meaning
	# end

end
