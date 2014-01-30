class EI
	attr_accessor :income

	def initialize (income)
		@income = income
	end

	def premium
  		@income < $eiMax[$year] ? premium = @income*$eiRate[$year] : premium = $eiMax[$year]*$eiRate[$year]
  		return premium
	end
end