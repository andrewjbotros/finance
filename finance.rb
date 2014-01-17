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
	attr_reader :firstName,:lastName,:fullName,:abbrName,:age,:sex,:province,:income,:tfsa,:ei,:cpp,:rrsp,:taxes

	def initialize (firstName, lastName, age, sex, province, income)
		@firstName = firstName
		@lastName = lastName
		@fullName = firstName + " " + lastName
		@abbrName = firstName + " " + lastName[0].upcase + "."
		@age = age
		@province = province
		@income = income
		@sex = sex
		@tfsa = TFSA.new(@age)
		@ei = EI.new(@income)
		@cpp = CPP.new(@income)
		@rrsp = RRSP.new(@income)
		@taxes = Taxes.new(@income, @province)
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
		decimals = decimals.to_i
		print " "*@@header + "PAYROLL DEDUCTIONS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Gross Income: $#{@income}\n"
		print " "*@@indent + "CPP Premiums: $#{@cpp.premium.round}\n"
		print " "*@@indent + "EI Premiums: $#{@ei.premium.round}\n"
		print " "*@@indent + "Tax (Provincial): $#{@taxes.incomeTax(@province).round}\n"
		print " "*@@indent + "Tax (Federal): $#{@taxes.incomeTax("Federal").round}\n"
		print " "*@@indent + "Net Income: $#{@income - (@cpp.premium.round + @ei.premium.round + @taxes.incomeTax(@province).round + @taxes.incomeTax("Federal").round)}\n"
		print "-"*@@width + "\n"
	end

	def payrollDeductionsPercent
		decimals = decimals.to_i
		print " "*@@header + "PAYROLL DEDUCTIONS (%)\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Gross Income: 100%\n"
		print " "*@@indent + "CPP Premiums: #{(@cpp.premium*100/@income).round(2)}%\n"
		print " "*@@indent + "EI Premiums: #{(@ei.premium*100/@income).round(2)}%\n"
		print " "*@@indent + "Tax (Provincial): #{(@taxes.incomeTax(@province)*100/@income).round(2)}%\n"
		print " "*@@indent + "Tax (Federal): #{(@taxes.incomeTax("Federal")*100/@income).round(2)}%\n"
		print " "*@@indent + "Net Income: #{((@income - (@cpp.premium + @ei.premium + @taxes.incomeTax(@province) + @taxes.incomeTax("Federal")))*100/@income).round(2)}%\n"
		print "-"*@@width + "\n"
	end

	def registeredSavings
		print " "*@@header + "ELIGIBLE CONTRIBUTIONS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "RRSP: $#{@rrsp.deduction.round}\n"
		print " "*@@indent + "TFSA: $#{@tfsa.contribution.round}\n"
		print " "*@@indent + "Total: $#{@rrsp.deduction.round + @tfsa.contribution.round}\n"
		print " "*@@indent + "Net Income: #{((@rrsp.deduction + @tfsa.contribution)*100/(@income - (@cpp.premium + @ei.premium + @taxes.incomeTax(@province) + @taxes.incomeTax("Federal")))).round(2)}%\n"
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

	def taxBracket
		k = 0

		while k < @@taxRates2013[@province].length
			if @income < @@taxRates2013[@province][k][1]
				return k + 1
			else
				k += 1
			end
		end

		return k
	end

	def incomeTax (province)
		i = 0
		incomeTax = 0
		incomeCount = @income
		incomeSum = 0
		bracket = taxBracket

		if @income < @@taxBasic2013[province]
		 	incomeTax = 0
		elsif province == "AB"
			incomeTax = @income*@@taxRates2013[province][0][0] - @@taxBasic2013[province]*@@taxRates2013[province][0][0]
		elsif @income <= @@taxRates2013[province][-1][1]
			while i < bracket - 1
				if @income > @@taxRates2013[province][i][0]
					incomeTax += @@taxRates2013[province][i][0]*@@taxRates2013[province][i][1]
					incomeSum += @@taxRates2013[province][i][1]
					i +=1
				else
					incomeTax += @@taxRates2013[province][i][0]*(@income - incomeSum)
				end
			end
		else
			while i < @@taxRates2013[province].length - 1
				if incomeCount > @@taxRates2013[province][i][1]
					incomeTax += @@taxRates2013[province][i][0]*@@taxRates2013[province][i][1]
					incomeCount = incomeCount - @@taxRates2013[province][i][1]
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

User = Finance.new("Peter", "Pan", "35", "M", "ON", 85000)
puts User.personalInfo
sleep(1.2)
puts User.payrollDeductions
sleep(1.2)
puts User.payrollDeductionsPercent
sleep(1.2)
puts User.registeredSavings
