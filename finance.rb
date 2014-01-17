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
		print " "*@@indent + "Tax (Provincial): $#{@taxes.provincialTaxes.round}\n"
		#print " "*@@indent + "Tax (Federal): $#{@taxes.federalTaxes}\n"
		print " "*@@indent + "Net Income: $#{@income - (@cpp.premium.round + @ei.premium.round + @taxes.provincialTaxes.round)}\n"
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

	def marginalBracket
		puts "#{@@taxRates2013[@province].length}"
	end

	def provincialTaxes
		i = 0
		incomeTax = 0
		incomeTemp = @income

		if @income < @@taxBasic2013[@province]
		 	incomeTax = 0
		elsif @province == "AB"
			incomeTax = @income*@@taxRates2013[@province][0][0] - @@taxBasic2013[@province]*@@taxRates2013[@province][0][0]
		elsif @income <= @@taxRates2013[@province][-1][1]
			incomeTax = 10
		else
			while i < @@taxRates2013[@province].length - 1
				if incomeTemp > @@taxRates2013[@province][i][1]
					incomeTax += @@taxRates2013[@province][i][0]*@@taxRates2013[@province][i][1]
					incomeTemp = incomeTemp - @@taxRates2013[@province][i][1]
					i += 1
				end
			end
			incomeTax += incomeTemp*@@taxRates2013[@province][-1][0] - @@taxBasic2013[@province]*@@taxRates2013[@province][0][0]
		end
		# 	puts "Income: #{@income}"
		# 	puts "Max Income Bracket: #{@@taxRates2013[@province][-1][1]}"

		# else
		# 	#case 1: income less than minimum basic amount, tax = 0
		# 	#case 2: income greater than maximum amount, a1*b1 + a2*b2 + ... an*(income - bn)
		# 	#case 3: income less than maximum amount: 	i) income*b1
		# 	#											ii) a1*b1 + a2*(income - b1)
		# 	#                                           iii) a1*b1 + a2*b2 + a3*(income - b2) ...
		# 	incomeTax = 1000000000000
		# end
		# return incomeTax
		return incomeTax
	end
			
			

	def federalTaxes
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

User = Finance.new("Peter", "Pan", "30", "M", "AB", 100000)
puts User.personalInfo
sleep(1.2)
puts User.payrollDeductions
sleep(1.2)
puts User.registeredSavings
User.taxes.marginalBracket
