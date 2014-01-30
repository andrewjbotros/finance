class Taxes
	attr_accessor :income,:province

	def initialize (income, province)
		@income = income
		@province = province
	end


	#create a new array, and make the income bracket cumulative (instead of additive)
	#compare the income against each cumulative amount, and return the tax bracket
	#take the marginal product of the rate and the cap, ending with the rate times remaining income

	def incomeTax
		rates = $taxRates2013

		$taxRates2013.each do |province, bracket|
			sum = 0
			(0...bracket.length).each do |i|
				sum += bracket[i][1]
				rates[province][i][1] = sum
			end
		end

		rates.each do |province, bracket|
			(0...bracket.length).each do |i|
				if @income < bracket[i][1].to_f
					return "#{i}"
				else
					puts "#{rates[@province].length}"
				end
			end
		end
	end
end