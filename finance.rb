#           ##########################################################
#           ##############                             ###############
#           ##############        LOAD RUBY GEMS       ###############
#           ##############                             ###############
#           ##########################################################

require 'Time'
require 'csv'

#           ##########################################################
#           ##############                             ###############
#           ##############     LOAD RELEVANT FILES     ###############
#           ##############                             ###############
#           ##########################################################

require_relative 'finance_dictionary'

#           ##########################################################
#           ##############                             ###############
#           ##############         CREATE STUFF        ###############
#           ##############                             ###############
#           ##########################################################

class Finance
	attr_reader :firstName,:lastName,:age,:sex,:province,:income,
				:fullName,:abbrName,
				:ei,:cpp,:taxes,:rrsp,:tfsa,
				:taxBracket,:federalTax,:provincialTax,:incomeTax,:allTax,:avgTax,:marginalTax,
				:netincome
	#

	def initialize (firstName, lastName, age, sex, province, income)
		@firstName = firstName
		@lastName = lastName
		@age = age
		@sex = sex
		@province = province
		@income = income

		@fullName = firstName + " " + lastName
		@abbrName = firstName + " " + lastName[0].upcase + "."

		@ei = EI.new(@income)
		@cpp = CPP.new(@income)
		@taxes = Taxes.new(@income, @province)
		@rrsp = RRSP.new(@income)
		@tfsa = TFSA.new(@age)

		@taxBracket = @taxes.taxBracket(@province)
		@federalTax = @taxes.incomeTax("Federal")
		@provincialTax = @taxes.incomeTax(@province)
		@incomeTax = @provincialTax + @federalTax
		@allTax = @cpp.premium + @ei.premium + @incomeTax
		@avgTax = (@incomeTax/@income)*100
		@marginalTax = @@taxRates2013[@province][@taxBracket-1][0]*100
	 	@netincome = (@income - (@cpp.premium + @ei.premium + @provincialTax + @federalTax))
	end

	def additionalParameters

	end

	def personalInfo
		print "\n" + " "*@@header + "PERSONAL INFORMATION\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Name: #{@fullName}\n"
		print " "*@@indent + "Age: #{@age}\n"
		print " "*@@indent + "Sex: #{@sex.upcase}\n"
		print " "*@@indent + "Province: #{@province}\n"
		print "-"*@@width + "\n"
	end

	def payrollDeductions
		print " "*@@header + "PAYROLL DEDUCTIONS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Gross Income: $#{@income}\n"
		print " "*@@indent + "CPP Premiums: $#{@cpp.premium.round}\n"
		print " "*@@indent + "EI Premiums: $#{@ei.premium.round}\n"
		print " "*@@indent + "Tax (Provincial): $#{@provincialTax}\n"
		print " "*@@indent + "Tax (Federal): $#{@federalTax}\n"
		print " "*@@indent + "Net Income: $#{@netincome}\n"
		print "-"*@@width + "\n"
	end

	def payrollDeductionsPercent
		decimals = decimals.to_i
		print " "*@@header + "PAYROLL DEDUCTIONS (%)\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Gross Income: 100%\n"
		print " "*@@indent + "CPP Premiums: #{(@cpp.premium*100/@income).round(2)}%\n"
		print " "*@@indent + "EI Premiums: #{(@ei.premium*100/@income).round(2)}%\n"
		print " "*@@indent + "Tax (Provincial): #{(@provincialTax*100/@income).round(2)}%\n"
		print " "*@@indent + "Tax (Federal): #{(@federalTax*100/@income).round(2)}%\n"
		print " "*@@indent + "Net Income: #{(@netincome*100/@income).round(2)}%\n"
		print "-"*@@width + "\n"
	end

	def registeredSavings
		print " "*@@header + "ELIGIBLE CONTRIBUTIONS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "RRSP: $#{@rrsp.deduction.round}\n"
		print " "*@@indent + "TFSA: $#{@tfsa.contribution.round}\n"
		print " "*@@indent + "Total Contributions: $#{@rrsp.deduction.round + @tfsa.contribution.round}\n"
		print " "*@@indent + "Net Income: #{((@rrsp.deduction + @tfsa.contribution)*100/(@income - (@cpp.premium + @ei.premium + @taxes.incomeTax(@province) + @taxes.incomeTax("Federal")))).round(2)}%\n"
		print "-"*@@width + "\n"
	end

	def taxPersonal
		print " "*@@header + "TAX INFORMATION\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Total: $#{@rrsp.deduction.round}\n"
		print " "*@@indent + "Average Rate: $#{@tfsa.contribution.round}\n"
		print " "*@@indent + "Marginal Rate: $#{@rrsp.deduction.round + @tfsa.contribution.round}\n"
		print " "*@@indent + "Tax Bracket: #{((@rrsp.deduction + @tfsa.contribution)*100/(@income - (@cpp.premium + @ei.premium + @taxes.incomeTax(@province) + @taxes.incomeTax("Federal")))).round(2)}%\n"
		print "-"*@@width + "\n"
	end

	def taxProvincial
		print " "*@@header + "TAX INFORMATION\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Total: $#{@provincialTax}\n"
		print " "*@@indent + "Average Rate: $#{@tfsa.contribution.round}\n"
		print " "*@@indent + "Marginal Rate: $#{@rrsp.deduction.round + @tfsa.contribution.round}\n"
		print " "*@@indent + "Tax Bracket: #{((@rrsp.deduction + @tfsa.contribution)*100/(@income - (@cpp.premium + @ei.premium + @taxes.incomeTax(@province) + @taxes.incomeTax("Federal")))).round(2)}%\n"
		print "-"*@@width + "\n"
	end

end

class CPP
	def initialize (income)
		@income = income
	end
	def premium
		premium = 0
		if @income < @@cppMinimum[@@year]
			premium = 0
		elsif @income < @@YMPE[@@year]
			premium = (@income - @@cppMinimum[@@year])*@@cppRate[@@year]
		else
			premium = (@@YMPE[@@year] - @@cppMinimum[@@year])*@@cppRate[@@year]
		end
		return premium
	end
end

class EI
	def initialize (income)
		@income = income
	end
	def premium
		premium = 0
		if @income < @@eiMax[@@year]
			premium = @income*@@eiRate[@@year]
		else
			premium = @@eiMax[@@year]*@@eiRate[@@year]
		end
		return premium
	end
end

class RRSP
	def initialize (income)
		@income = income
	end

	def deduction
		deduction = 0
		if @income*@@rrspRate[@@year] < @@rrspMax[@@year]
			deduction = @income*@@rrspRate[@@year]
		else
			deduction = @@rrspMax[@@year]
		end
		return deduction
	end
end

class Taxes

	def initialize(income, province)
		@income = income
		@province = province
	end

	def taxBracket (prov)
		k = 0

		while k < @@taxRates2013[prov].length
			if @income < @@taxRates2013[prov][k][1]
				return k + 1
			else
				k += 1
			end
		end

		return k
	end

	def incomeTax (prov)
		i = 0
		incomeTax = 0
		incomeSum = 0
		bracket = taxBracket(prov)

		if @income < @@taxBasic2013[prov]
		 	incomeTax = 0

		elsif prov == "AB"
			incomeTax = @income*@@taxRates2013[prov][0][0] - @@taxBasic2013[prov]*@@taxRates2013[prov][0][0]
		elsif @income <= @@taxRates2013[prov][-1][1]
			while i < bracket - 1
				if @income > @@taxRates2013[prov][i][0]
					incomeTax += @@taxRates2013[prov][i][0]*@@taxRates2013[prov][i][1]
					incomeSum += @@taxRates2013[prov][i][1]
					i +=1
				else
					incomeTax += (@@taxRates2013[prov][i][0]*(@income - incomeSum) - @@taxBasic2013[prov]*@@taxRates2013[prov][0][0])
				end
			end

		else
			incomeSum = @income
			while i < bracket - 1
				if incomeSum > @@taxRates2013[prov][i][1]
					incomeTax += @@taxRates2013[prov][i][0]*@@taxRates2013[prov][i][1]
					incomeSum -= @@taxRates2013[prov][i][1]
					i += 1
				end
			end
			incomeTax += incomeCount*@@taxRates2013[province][-1][0] - @@taxBasic2013[province]*@@taxRates2013[province][0][0]
		end

		return incomeTax
	end
end

class TFSA

	def initialize(age)
		@age = age.to_i
	end

	def contribution
		if @age < 18
			return 0
		else
			return @@tfsaAmount[@@year.to_s]
		end
	end

	def contributionTotal
		contributionRoom = 0
		count = @age
		year = @@currentYear.to_i

		if @age < 18
			return "Sorry, you must be 18 years of age to contribute to your TFSA."
		else
			while year >= 2009 && count >= 18
				contributionRoom += @@tfsaAmount[year.to_s]
				year -= 1
				count -= 1
			end
			return contributionRoom
		end
	end
end

#           ##########################################################
#           ##############        CREATE NEW USER;     ###############
#           ##############         PRINT RESULTS       ###############
#           ##############           (testing)         ###############
#           ##########################################################

User = Finance.new("Peter", "Pan", "35", "M", "ON", 60000)

puts User.firstName







