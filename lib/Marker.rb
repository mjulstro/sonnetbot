class Marker

	def initialize(gram_unit, syl_here, line_here)
		@gram_unit = gram_unit
		@syl = syl_here
		@line = line_here
	end

	def gram_unit
		@gram_unit
	end

	def syl
		@syl_here
	end

	def line
		@line
	end

	def to_s
		string = "<#{@gram_unit} Marker at line #{@line}, syllable #{@syl}>"
	end
	
end