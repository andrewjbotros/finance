class RRSP
	attr_accessor :income

	def initialize (income)
		@income = income
	end

	def contribution
  		@income < $rrspMax[$year] ? contribution = @income*$rrspRate[$year] : contribution = $rrspRate[$year]*$rrspMax[$year]
  		return contribution
	end
end