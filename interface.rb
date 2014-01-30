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
require_relative 'user'
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

class Interface
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
end

#           ##########################################################
#           ##############        CREATE NEW USER;     ###############
#           ##############         PRINT RESULTS       ###############
#           ##############           (testing)         ###############
#           ##########################################################

finance = Finance.new("Peter", "Pan", "23", "M", "ON", 150000)
puts finance.ei.premium
puts finance.cpp.premium
puts finance.rrsp.contribution
puts finance.ei.rate
puts finance.cpp.rate
