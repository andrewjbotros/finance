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

@@taxRates2013 = {}
@@taxRates2013["NL"] = [[7.7, 33748], [12.5, 33748], [13.3, 67496]]
@@taxRates2013["PE"] = [[9.8, 31984], [13.8, 31985], [16.7, 63969]]
@@taxRates2013["NS"] = [[8.79, 29590], [14.95, 29590],[16.67, 33820], [17.5, 57000], [21, 150000]
@@taxRates2013["NB"] = [[9.39, 38954], [13.46, 38954], [14.46, 48754], [16.07, 126662]]
@@taxRates2013["QC"] = [[16, 41095], [20, 41095], [24, 17810], [25.75, 100000]]
@@taxRates2013["ON"] = [[5.05, 39723], [9.15, 39725], [11.16, 429552], [13.16, 509000]]
@@taxRates2013["MB"] = [[10.8, 31000],[12.75, 36000], [17.4, 67000]]
@@taxRates2013["SK"] = [[11, 42906], [13, 79683], [15, 122589]]
@@taxRates2013["AB"] = 10
@@taxRates2013["BC"] = [[5.06, 37568],[7.7, 37570],[10.5, 11130],[12.29, 18486],[14.7, 104754]
@@taxRates2013["YT"] = [[9.8, 31984], [13.8, 31985], [16.7, 63969]]
@@taxRates2013["NT"] = [[9.8, 31984], [13.8, 31985], [16.7, 63969]]
@@taxRates2013["NU"] = [[9.8, 31984], [13.8, 31985], [16.7, 63969]]
@@taxRates2013["Federal"] = [[9.8, 31984], [13.8, 31985], [16.7, 63969]]

        'BC': [(5.06, 37568),
               (7.7, 37570),
               (10.5, 11130),
               (12.29, 18486),
               (14.7, 104754)],
        'YT': [(7.04, 43561),
               (9.68, 43562),
               (11.44, 47931),
               (12.76, 135054)],
        'NT': [(5.9, 39453),
               (8.6, 39455),
               (12.2, 49378),
               (14.05, 128286)],
        'NU': [(4, 41535),
               (7, 41536),
               (9, 51983),
               (11.5, 135054)],
        'Federal': [(15, 43561),
                    (22, 43562),
                    (26, 47931),
                    (29, 135054)]
    }

    basic = {
        'AB': 17593,
        'BC': 10276,
        'Federal': 11038,
        'MB': 8884,
        'NB': 9388,
        'NL': 8451,
        'NT': 13546,
        'NS': 8481,
        'NU': 12455,
        'ON': 9574,
        'PE': 7708,
        'QC': 11195,
        'SK': 15241,
        'YT': 11038,
    }



class Finance

	attr_reader :firstName,:lastName,:age,:province,:income,:tfsa,:ei,:cpp,:rrsp

	def initialize (firstName, lastName, age, province, income)
		@firstName = firstName
		@lastName = lastName
		@age = age
		@province = province
		@income = income
		@tfsa = TFSA.new(@age)
		@ei = EI.new(@income)
		@cpp = CPP.new(@income)
		@rrsp = RRSP.new(@income)
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

	def payrollDeductions (decimals)
		decimals = decimals.to_i
		print " "*@@header + "PAYROLL DEDUCTIONS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "CPP Premiums: #{@cpp.premium.round(decimals)}\n"
		print " "*@@indent + "EI Premiums: #{@ei.premium.round(decimals)}\n"
		print " "*@@indent + "Tax (Provincial): #{@ei.premium.round(decimals)}\n"
		print " "*@@indent + "Tax (Federal): #{@income.round(decimals)}\n"
		print " "*@@indent + "Total($): #{@income.round(decimals)}\n"
		print "-"*@@width + "\n"
	end

	def registeredSavings
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

class RRSP

	def initialize (income)
		@income = income
	end

	def premium
		contribution = 0
		if @income < @@rrspMax[@@currentYear]
			contribution = @income*@@rrspRate[@@currentYear]
		else
			contribution = @@rrspMax[@@currentYear]*@@rrspRate[@@currentYear]
		end
		return contribution
	end

end

User = Finance.new("Peter", "Pan", "30", "Ontario", 80000)
puts User.personalInfo
puts User.payrollDeductions(3)


