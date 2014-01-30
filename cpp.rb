class CPP
	attr_accessor :income

	def initialize (income)
		@income = income
	end

	def premium
		@income > $cppMin[$year] ? premium = $cppRate[$year]*[@income - $cppMin[$year], $YMPE[$year] - $cppMin[$year]].min : premium = 0
		return premium
	end

	def rate
		return $cppRate[$year]
	end

end