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
require_relative 'ei'
require_relative 'cpp'
require_relative 'rrsp'
require_relative 'taxes'
require_relative 'tfsa'

#           ##########################################################
#           ##############                             ###############
#           ##############         CREATE STUFF        ###############
#           ##############                             ###############
#           ##########################################################

class Finance
	attr_writer :income,:province
	attr_reader :firstName,:lastName,:age,:sex,:province,:income,
				:fullName,:abbrName,
				:ei,:cpp,:taxes,:rrsp,:tfsa

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
		@rrsp = RRSP.new(@income)
		@taxes = Taxes.new(@income, @province)
		@tfsa = TFSA.new(@age)

	end

	def update (userIncome)
		@income = userIncome
		@ei.income = userIncome
		@cpp.income = userIncome
		@rrsp.income = userIncome
		@taxes.income = userIncome
	end

	def info
		print "\n" + " "*$header + "PERSONAL INFORMATION\n"
		print "-"*$width + "\n"
		print " "*$indent + "Name: #{@fullName}\n"
		print " "*$indent + "Age: #{@age}\n"
		print " "*$indent + "Sex: #{@sex.upcase}\n"
		print " "*$indent + "Province: #{@province}\n"
		print "-"*$width + "\n"
	end

	def deductions
		print " "*$header + "PAYROLL DEDUCTIONS\n"
		print "-"*$width + "\n"
		print " "*$indent + "Gross Income: $#{@income}\n"
		print " "*$indent + "CPP Premiums: $#{@cpp.premium.round}\n"
		print " "*$indent + "EI Premiums: $#{@ei.premium.round}\n"
		print " "*$indent + "Tax (Provincial): $#{@taxes.incomeTax(@province)}\n"
		print " "*$indent + "Tax (Federal): $#{@taxes.incomeTax("Federal")}\n"
		print " "*$indent + "Net Income: $#{@income - @cpp.premium - @ei.premium - @taxes.incomeTax(@province) - @taxes.incomeTax("Federal")}\n"
		print "-"*$width + "\n"
	end

	def deductionsPercent
		print " "*$header + "PAYROLL DEDUCTIONS (%)\n"
		print "-"*$width + "\n"
		print " "*$indent + "CPP Premiums: #{(@cpp.premium*100/@income).round(2)}%\n"
		print " "*$indent + "EI Premiums: #{(@ei.premium*100/@income).round(2)}%\n"
		print " "*$indent + "Tax (Provincial): #{(@taxes.incomeTax(@province)*100/@income).round(2)}%\n"
		print " "*$indent + "Tax (Federal): #{(@taxes.incomeTax("Federal")*100/@income).round(2)}%\n"
		print " "*$indent + "Net Income: #{((@income - @cpp.premium - @ei.premium - @taxes.incomeTax(@province) - @taxes.incomeTax("Federal"))*100/@income).round(2)}%\n"
		print "-"*$width + "\n"
	end

	def registeredSavings
		print " "*$header + "ELIGIBLE CONTRIBUTIONS\n"
		print "-"*$width + "\n"
		print " "*$indent + "RRSP: $#{@rrsp.deduction.round}\n"
		print " "*$indent + "TFSA: $#{@tfsa.contribution.round}\n"
		print " "*$indent + "Total Contributions: $#{@rrsp.deduction.round + @tfsa.contribution.round}\n"
		print " "*$indent + "Net Income: #{((@rrsp.deduction + @tfsa.contribution)*100/(@income - (@cpp.premium + @ei.premium + @taxes.incomeTax(@province) + @taxes.incomeTax("Federal")))).round(2)}%\n"
		print "-"*$width + "\n"
	end

	def taxSummary
		print " "*$header + "TAX INFORMATION\n"
		print "-"*$width + "\n"
		print " "*$indent + "Total: $#{@rrsp.deduction.round}\n"
		print " "*$indent + "Average Rate: $#{@tfsa.contribution.round}\n"
		print " "*$indent + "Marginal Rate: $#{@rrsp.deduction.round + @tfsa.contribution.round}\n"
		print " "*$indent + "Tax Bracket: #{((@rrsp.deduction + @tfsa.contribution)*100/(@income - (@cpp.premium + @ei.premium + @taxes.incomeTax(@province) + @taxes.incomeTax("Federal")))).round(2)}%\n"
		print "-"*$width + "\n"
	end
end

#           ##########################################################
#           ##############        CREATE NEW USER;     ###############
#           ##############         PRINT RESULTS       ###############
#           ##############           (testing)         ###############
#           ##########################################################

finance = Finance.new("Peter", "Pan", "23", "M", "ON", 3600)
puts finance.ei.premium
puts finance.cpp.premium
puts finance.rrsp.contribution
finance.info
finance.deductionsPercent
