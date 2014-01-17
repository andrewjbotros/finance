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

	def registeredSavings
		print " "*@@header + "REGISTERED SAVINGS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "RRSP Contribution: $#{@rrsp.deduction.round}\n"
		print " "*@@indent + "TFSA Contribution: $#{@tfsa.contribution.round}\n"
		print " "*@@indent + "Total: $#{@rrsp.deduction.round + @tfsa.contribution.round}\n"
		print "-"*@@width + "\n"
	end
end

class CPP
	def initialize (income)
		@income = income
	end
	def premium
		premium = 0
		if @income < @@YMPE[@@currentYear]
			premium = @income*@@cppRate[@@currentYear]
		else
			premium = @@YMPE[@@currentYear]*@@cppRate[@@currentYear]
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
		if @income < @@eiMax[@@currentYear]
			premium = @income*@@eiRate[@@currentYear]
		else
			premium = @@eiMax[@@currentYear]*@@eiRate[@@currentYear]
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
		if @income*@@rrspRate[@@currentYear] < @@rrspMax[@@currentYear]
			deduction = @income*@@rrspRate[@@currentYear]
		else
			deduction = @@rrspMax[@@currentYear]
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
					puts "#{incomeSum}"
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
			return @@tfsaAmount[@@currentYear.to_s]
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

User = Finance.new("Peter", "Pan", "30", "M", "ON", 600000)
puts User.personalInfo
sleep(1.2)
puts User.payrollDeductions
sleep(1.2)
puts User.registeredSavings
