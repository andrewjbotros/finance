#load necessary Ruby Gems
require 'Time'

#We want to load up some global various to be used throughout various methods

@@width = 50
@@indent = 3
@@header = (@@width*1/4).to_i

@@currentYear = Time::new.year.to_s

@@eiRate = {}
@@eiRate["2014"] = 0.0188
@@eiRate["2013"] = 0.0188

@@eiMax={}
@@eiMax["2014"] = 48600
@@eiMax["2013"] = 47400

@@cppRate = {}
@@cppRate["2014"] = 0.0495
@@cppRate["2013"] = 0.0495

@@cppMax={}
@@cppMax["2014"] = 52500
@@cppMax["2013"] = 51100
@@cppMax["2012"] = 50100

@@tfsaAmount = {}
@@tfsaAmount["2014"] = 5500
@@tfsaAmount["2013"] = 5500
@@tfsaAmount["2012"] = 5000
@@tfsaAmount["2011"] = 5000
@@tfsaAmount["2010"] = 5000
@@tfsaAmount["2009"] = 5000



class Finance

	attr_reader :firstName,:lastName,:age,:province,:income,:tfsa,:ei,:cpp

	def initialize (firstName, lastName, age, province, income)
		@firstName = firstName
		@lastName = lastName
		@age = age
		@province = province
		@income = income
		@tfsa = TFSA.new(@age)
		@ei = EI.new(@income)
		@cpp = CPP.new(@income)
	end

	def personalInfo
		print "\n" + " "*@@header + "PERSONAL INFORMATION\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Name: #{@firstName} #{@lastName}\n"
		print " "*@@indent + "Age: #{@age}\n"
		print " "*@@indent + "Province: #{@province}\n"
		print " "*@@indent + "Income: #{@income}\n"
		print "-"*@@width + "\n"
	end

	def payrollDeductions
		print " "*@@header + "PAYROLL DEDUCTIONS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "CPP Premiums: #{@cpp.premium}\n"
		print " "*@@indent + "EI Premiums: #{@ei.premium}\n"
		print " "*@@indent + "Tax (Provincial): #{@province}\n"
		print " "*@@indent + "Tax (Federal): #{@income}\n"
		print " "*@@indent + "Total($): #{@income}\n"
		print "-"*@@width + "\n"
	end
	
end

class TFSA

	def initialize(age)
		@age = age.to_i
	end

	def room
		contributionRoom = 0
		count = @age
		year = @@currentYear.to_i

		if @age < 18
			puts "Sorry, you must be 18 years of age to contribute to your TFSA."
		else
			while year >= 2009 && count >= 18
				contributionRoom += @@tfsaAmount[year.to_s]
				year -= 1
				count -= 1
			end
			print "You can contribute #{contributionRoom} to your TFSA."
		end
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

class CPP

	def initialize (income)
		@income = income
	end

	def premium
		premium = 0
		if @income < @@cppMax[@@currentYear]
			premium = @income*@@cppRate[@@currentYear]
		else
			premium = @@cppMax[@@currentYear]*@@cppRate[@@currentYear]
		end
		return premium
	end

end

User = Finance.new("Peter", "Pan", "30", "Ontario", 80000)
puts User.personalInfo
puts User.payrollDeductions


