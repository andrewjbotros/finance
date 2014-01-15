#load necessary Ruby Gems
require 'Time'

#We want to load up some global various to be used throughout various methods
@@currentYear = Time::new.year

#The Tax Free Savings Account (TFSA) started in 2009 with contributions for anyone 18 and older capped at 5,000. In 2012, that was increased to 5,500
@@tfsaAmount = {}
@@tfsaAmount["2009"] = 5000
@@tfsaAmount["2010"] = 5000
@@tfsaAmount["2011"] = 5000
@@tfsaAmount["2012"] = 5000
@@tfsaAmount["2013"] = 5500
@@tfsaAmount["2014"] = 5500
#puts @@contributionRates

class Finance

	attr_reader :firstName,:lastName,:age,:province,:income,:tfsa,:ei

	def initialize (firstName, lastName, age, province, income)
		@firstName = firstName
		@lastName = lastName
		@age = age
		@province = province
		@income = income
	end

	def tfsa
		@tfsa = TFSA.new(@age)
	end

	def ei
		@ei = EI.new(@income)
	end
	
end

class TFSA

	def initialize(age)
		@age = age.to_i
	end

	def room
		contributionRoom = 0
		count = @age
		year = @@currentYear

		if @age < 18
			puts "Sorry, you must be 18 years of age to contribute to your TFSA."
		else
			while year >= 2009 && count >= 18
				contributionRoom += @@tfsaAmount[year.to_s]
				year -= 1
				count -= 1
			end
			puts "You can contribute #{contributionRoom} to your TFSA."
		end
	end
end

class EI

	def initialize (income)
		@income = income
	end

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

User = Finance.new("Andrew", "Botros", "28", "Ontario", 35000)
puts User.age
puts User.province
puts User.lastName
puts User.firstName
puts User.tfsa.room

