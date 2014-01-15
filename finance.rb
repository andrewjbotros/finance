#The Tax Free Savings Account (TFSA) started in 2009 with contributions for anyone 18 and older capped at 5,000. In 2012, that was increased to 5,500
@@contributionRates = {}
@@contributionRates["2009"] = 5000
@@contributionRates["2010"] = 5000
@@contributionRates["2011"] = 5000
@@contributionRates["2012"] = 5000
@@contributionRates["2013"] = 5500
@@contributionRates["2014"] = 5500
puts @@contributionRates

class Finance

#2013 Employment Insurance (EI) Premiums for Individuals and Companies
	def employmentInsurance (income)
		if income < 47400
			return income*0.0188
		else
			return 47400*0.0188
		end
	end

#Display: Computing EI Premium
	def employmentInsuranceDisplay
		puts "Enter your income: "
		income = gets.strip.to_f
		puts "Your EI premium contribution is: #{employmentInsurance(income)}"
	end

end

User = Finance.new
User.employmentInsuranceDisplay
