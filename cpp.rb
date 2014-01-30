class CPP
	attr_accessor :income

	def initialize (income)
		@income = income
	end

	def premium
		@income > $cppMinimum[$year] ? premium = $cppRate[$year]*[@income - $cppMinimum[$year], $YMPE[$year] - $cppMinimum[$year]].min : premium = 0
		return premium
	end
end