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

	def greeting
		puts "Hello #{@firstName} #{@lastName}, age #{@age} from #{@province}. You make #{@income}. Good job!"
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
			print "You can contribute #{contributionRoom} to your TFSA."
		end
	end
end

class EI

	def initialize (income)
		@income = income
	end

	def contributions
		premium = 0
		if @income < 47400
			premium = @income*0.0188
		else
			premium = 47400*0.0188
		end
		print "You will contribute #{premium} to Employment Insurance."
	end

end

User = Finance.new("Andrew", "Botros", "28", "Ontario", 35000)
puts User.greeting
puts User.tfsa.room
puts User.ei.contributions

