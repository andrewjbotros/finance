#           ##########################################################
#           ##############                             ###############
#           ##############    LOAD APPROPRIATE GEMS    ###############
#           ##############                             ###############
#           ##########################################################

require 'Time'
require 'csv'

#           ##########################################################
#           ##############                             ###############
#           ##############     LOAD RELEVANT FILES     ###############
#           ##############                             ###############
#           ##########################################################

#require_relative 'Time'

#           ##########################################################
#           ##############                             ###############
#           ##############     INPUT RELEVANT DATA     ###############
#           ##############                             ###############
#           ##########################################################

#                SET FORMAT PARAMETERS, CURRENT YEAR, PROVINCE ABBR.   
#           ##########################################################

@@width = 50
@@indent = 3
@@header = (@@width*6/20).to_i

@@currentYear = Time::new.year.to_s

#                            EMPLOYMENT INSURANCE (EI)    
#           ##########################################################

@@eiRate = {}
@@eiRate["2014"] = 0.0188
@@eiRate["2013"] = 0.0188

@@eiMax={}
@@eiMax["2014"] = 48600
@@eiMax["2013"] = 47400

#                           CANADA PENSION PLAN (CPP)     
#           ##########################################################

@@cppRate = {}
@@cppRate["2014"] = 0.0495
@@cppRate["2013"] = 0.0495

@@YMPE={}
@@YMPE["2014"] = 52500
@@YMPE["2013"] = 51100
@@YMPE["2012"] = 50100
@@YMPE["2011"] = 48300
@@YMPE["2010"] = 47200
@@YMPE["2009"] = 46300
@@YMPE["2008"] = 44900
@@YMPE["2007"] = 43700
@@YMPE["2006"] = 42100
@@YMPE["2005"] = 41100
@@YMPE["2004"] = 40500
@@YMPE["2003"] = 39900
@@YMPE["2002"] = 39100
@@YMPE["2001"] = 38300
@@YMPE["2000"] = 37600
@@YMPE["1999"] = 37400
@@YMPE["1998"] = 36900
@@YMPE["1997"] = 35800
@@YMPE["1996"] = 35400
@@YMPE["1995"] = 34900
@@YMPE["1994"] = 34400
@@YMPE["1993"] = 33400
@@YMPE["1992"] = 32200
@@YMPE["1991"] = 30500
@@YMPE["1990"] = 28900

#                   REGISTERED RETIREMENT SAVINGS PLAN (RRSP)   
#           ##########################################################

@@rrspMax = {}
@@rrspMax["2014"] = 24270
@@rrspMax["2013"] = 23820

@@rrspRate = {}
@@rrspRate["2014"] = 0.18
@@rrspRate["2013"] = 0.18

#                        TAX FREE SAVINGS ACCOUNT (TFSA)    
#           ##########################################################

@@tfsaAmount = {}
@@tfsaAmount["2014"] = 5500
@@tfsaAmount["2013"] = 5500
@@tfsaAmount["2012"] = 5000
@@tfsaAmount["2011"] = 5000
@@tfsaAmount["2010"] = 5000
@@tfsaAmount["2009"] = 5000

#                   PROVINCIAL AND FEDERAL INCOME TAX RATES   
#           ##########################################################

@@taxRates2013 = {}
@@taxRates2013["AB"] = 10
@@taxRates2013["BC"] = [[5.06, 37568],[7.7, 37570],[10.5, 11130],[12.29, 18486],[14.7, 104754]]
@@taxRates2013["Federal"] = [[15, 43561], [22, 43562], [26, 47931], [29, 135054]]
@@taxRates2013["MB"] = [[10.8, 31000],[12.75, 36000], [17.4, 67000]]
@@taxRates2013["NB"] = [[9.39, 38954], [13.46, 38954], [14.46, 48754], [16.07, 126662]]
@@taxRates2013["NL"] = [[0.077, 33748], [0.125, 33748], [0.133, 67496]]
@@taxRates2013["NT"] = [[5.9, 39453], [8.6, 39455], [12.2, 49378], [14.05, 128286]]
@@taxRates2013["NS"] = [[8.79, 29590], [14.95, 29590],[16.67, 33820], [17.5, 57000], [21, 150000]]
@@taxRates2013["NU"] = [[4, 41535], [7, 41536], [9, 51983], [11.5, 135054]]
@@taxRates2013["ON"] = [[0.0505, 39723], [0.0915, 39725], [0.1116, 429552], [0.1316, 509000]]
@@taxRates2013["PE"] = [[0.098, 31984], [13.8, 31985], [16.7, 63969]]
@@taxRates2013["QC"] = [[16, 41095], [20, 41095], [24, 17810], [25.75, 100000]]
@@taxRates2013["SK"] = [[11, 42906], [13, 79683], [15, 122589]]
@@taxRates2013["YT"] = [[7.04, 43561], [9.68, 43562], [11.44, 47931], [12.76, 135054]]

@@taxBasic2013 = {}
@@taxBasic2013["AB"] = 17593
@@taxBasic2013["BC"] = 10276
@@taxBasic2013["Federal"] = 11038
@@taxBasic2013["MB"] = 8884
@@taxBasic2013["NB"] = 9388
@@taxBasic2013["NL"] = 8451
@@taxBasic2013["NT"] = 13546
@@taxBasic2013["NS"] = 8481
@@taxBasic2013["NU"] = 12455
@@taxBasic2013["ON"] = 9574
@@taxBasic2013["PE"] = 7708
@@taxBasic2013["QC"] = 11195
@@taxBasic2013["SK"] = 15241
@@taxBasic2013["YT"] = 11038

#           ##########################################################
#           ##############                             ###############
#           ##############         CREATE STUFF        ###############
#           ##############                             ###############
#           ##########################################################

class Finance
	attr_reader :firstName,:lastName,:age,:province,:income,:tfsa,:ei,:cpp,:rrsp,:taxes

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
		@taxes = Taxes.new(@income, @province)
	end

	def personalInfo
		print "\n" + " "*@@header + "PERSONAL INFORMATION\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "Name: #{@firstName} #{@lastName}\n" 
		print " "*@@indent + "Age: #{@age}\n"
		print " "*@@indent + "Province: #{@province}\n"
		print " "*@@indent + "Income: $#{@income}\n"
		print "-"*@@width + "\n"
	end

	def payrollDeductions
		decimals = decimals.to_i
		print " "*@@header + "PAYROLL DEDUCTIONS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "CPP Premiums: $#{@cpp.premium.round}\n"
		print " "*@@indent + "EI Premiums: $#{@ei.premium.round}\n"
		print " "*@@indent + "Tax (Provincial): $#{@taxes.provincialTaxes}\n"
		print " "*@@indent + "Tax (Federal): $#{@taxes.federalTaxes}\n"
		print " "*@@indent + "Total: $#{@income.round}\n"
		print "-"*@@width + "\n"
	end

	def registeredSavings
		print " "*@@header + "REGISTERED SAVINGS\n"
		print "-"*@@width + "\n"
		print " "*@@indent + "RRSP Contribution: $#{@rrsp.contribution.round}\n"
		print " "*@@indent + "TFSA Contribution: $#{@tfsa.contribution.round}\n"
		print " "*@@indent + "Total: $#{@income}\n"
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

	def contribution
		contribution = 0
		if @income*@@rrspRate[@@currentYear] < @@rrspMax[@@currentYear]
			contribution = @income*@@rrspRate[@@currentYear]
		else
			contribution = @@rrspMax[@@currentYear]*@@rrspRate[@@currentYear]
		end
		return contribution
	end
end

class Taxes

	def initialize(income, province)
		@income = income
		@province = province
	end

	def provincialTaxes
		i = 0
		incomeTax = 0
		incomeTemp = @income

		if @income < @@taxBasic2013[@province]
			return 0
		else
			while incomeTemp > 0
				while i < @@taxRates2013[@province].length
				incomeTemp -= @@taxRates2013[@province][i][1]
				if @income > @@taxRates2013[@province][-1][1]
			while i < @@taxRates2013[@province].length
				incomeTax += @@taxRates2013[@province][i][0]*@@taxRates2013[@province][i][1]
				i += 1
			end
		
			return incomeTax
		end


		# while @income < @@taxRates2013[@province][-1][1]

		# if @income < @@taxRates2013[@province][-1][1]
		# 	puts "Your income: #{@income}"
		# 	puts "Your max tax: #{@@taxRates2013[@province][-1][1]}"
		# end
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
#           ##############        CREATE NEW USER      ###############
#           ##############         PRINT RESULTS       ###############
#           ##############           (testing)         ###############
#           ##########################################################

User = Finance.new("Peter", "Pan", "30", "ON", 100000)
puts User.personalInfo
puts User.payrollDeductions
puts User.registeredSavings
puts @@YMPE["2012"]


