class TFSA
	attr_accessor :age

	def initialize(age)
		@age = age.to_i
	end

	def contribution
		@age < 18 ? contribution = 0 : contribution = $tfsaAmount[$year.to_s]
		return contribution
	end

	def contributionTotal
		@age < 18 ? contributionYear = nil : contributionYear = [2009, $year.to_i - (@age - 18)].max
		sum = 0

		while contributionYear <= $year.to_i
			sum += $tfsaAmount[contributionYear.to_s]
			contributionYear += 1
		end
		return sum
	end
end