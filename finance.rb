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
		print "\n" + " "*@@header + "PERSONAL INFORMATION\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Name: #{@fullName}\n"
		print " "*@@indent + "Age: #{@age}\n"
		print " "*@@indent + "Sex: #{@sex.upcase}\n"
		print " "*@@indent + "Province: #{@province}\n"
		print "-"*@@width + "\n"
	end

	def deductions
		print " "*@@header + "PAYROLL DEDUCTIONS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Gross Income: $#{@income}\n"
		print " "*@@indent + "CPP Premiums: $#{@cpp.premium.round}\n"
		print " "*@@indent + "EI Premiums: $#{@ei.premium.round}\n"
		print " "*@@indent + "Tax (Provincial): $#{@taxes.incomeTax(@province)}\n"
		print " "*@@indent + "Tax (Federal): $#{@taxes.incomeTax("Federal")}\n"
		print " "*@@indent + "Net Income: $#{@income - @cpp.premium - @ei.premium - @taxes.incomeTax(@province) - @taxes.incomeTax("Federal")}\n"
		print "-"*@@width + "\n"
	end

	def deductionsPercent
		print " "*@@header + "PAYROLL DEDUCTIONS (%)\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "CPP Premiums: #{(@cpp.premium*100/@income).round(2)}%\n"
		print " "*@@indent + "EI Premiums: #{(@ei.premium*100/@income).round(2)}%\n"
		print " "*@@indent + "Tax (Provincial): #{(@taxes.incomeTax(@province)*100/@income).round(2)}%\n"
		print " "*@@indent + "Tax (Federal): #{(@taxes.incomeTax("Federal")*100/@income).round(2)}%\n"
		print " "*@@indent + "Net Income: #{((@income - @cpp.premium - @ei.premium - @taxes.incomeTax(@province) - @taxes.incomeTax("Federal"))*100/@income).round(2)}%\n"
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

	def taxSummary
		print " "*@@header + "TAX INFORMATION\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Total: $#{@rrsp.deduction.round}\n"
		print " "*@@indent + "Average Rate: $#{@tfsa.contribution.round}\n"
		print " "*@@indent + "Marginal Rate: $#{@rrsp.deduction.round + @tfsa.contribution.round}\n"
		print " "*@@indent + "Tax Bracket: #{((@rrsp.deduction + @tfsa.contribution)*100/(@income - (@cpp.premium + @ei.premium + @taxes.incomeTax(@province) + @taxes.incomeTax("Federal")))).round(2)}%\n"
		print "-"*@@width + "\n"
	end
end

class CPP
	attr_accessor :income

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
	attr_accessor :income

	def initialize(income)
		@income = income
	end
	def premium
  		@income < @@eiMax[@@year] ? premium = @income*@@eiRate[@@year] : premium = @@eiMax[@@year]*@@eiRate[@@year]
  		return premium
	end
end

class RRSP
	attr_accessor :income

	def initialize (income)
		@income = income
	end

	def contribution
  		@income*@@rrspRate[@@year] < @@rrspMax[@@year] ? contribution = @income*@@eiRate[@@year] : contribution = @@eiMax[@@year]*@@eiRate[@@year]
  		return contribution
	end
end

class TFSA
	attr_accessor :age

	def initialize(age)
		@age = age.to_i
	end

	def contribution
		@age < 18 ? contribution = 0 : contribution = @@tfsaAmount[@@year.to_s]
		return contribution
	end

	def contributionTotal
		contributionRoom = 0
		count = @age

		#How old were you in 2009? Current age - (Current Year - 2009)
		(Current Year - 2009) * @@tfsaAmount[@@year]

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

class Taxes
	attr_accessor :income,:province

	def initialize (income, province)
		@income = income
		@province = province
	end

	def incomeTax
		sum = 0
		(0...@@taxRates2013[@province].length).each do |i|
			sum += @@taxRates2013[@province][i][1]
			puts "#{sum}"
			if @income < sum
				bracket = i + 1
			else
				bracket = @@taxRates2013[@province].length - 1
			end
			return bracket
		end
	end
end

#           ##########################################################
#           ##############        CREATE NEW USER;     ###############
#           ##############         PRINT RESULTS       ###############
#           ##############           (testing)         ###############
#           ##########################################################

finance = Finance.new("Peter", "Pan", "35", "M", "ON", 10000)
puts finance.ei.premium
puts finance.tfsa.contribution
finance.update(40000)
puts finance.ei.premium
puts finance.tfsa.contribution

