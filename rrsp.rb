class RRSP
	attr_accessor :income

	def initialize (income)
		@income = income
	end

	def contribution
  		@income*$rrspRate[$year] < $rrspMax[$year] ? contribution = @income*$rrspRate[$year] : contribution = $rrspMax[$year]
  		return contribution
	end
end