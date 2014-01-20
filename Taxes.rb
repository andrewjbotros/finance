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
require_relative 'finance'

class Taxes
	attr_accessor :income,:province

	def initialize (income, province)
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

	def incomeTax (userProvince)
		i = 0
		incomeTax = 0
		incomeSum = 0
		bracket = taxBracket

		if @income < @@taxBasic2013[userProvince]
		 	incomeTax = 0

		elsif userProvince == "AB"
			incomeTax = @@taxRates2013[userProvince][0][0]*(@income - @@taxBasic2013[userProvince])

		elsif @income <= @@taxRates2013[userProvince][-1][1]
			while i < bracket - 1
				if @income > @@taxRates2013[userProvince][i][0]
					incomeTax += @@taxRates2013[userProvince][i][0]*@@taxRates2013[userProvince][i][1]
					incomeSum += @@taxRates2013[userProvince][i][1]
					i +=1
				else
					incomeTax += (@@taxRates2013[userProvince][i][0]*(@income - incomeSum) - @@taxBasic2013[userProvince]*@@taxRates2013[userProvince][0][0])
				end
			end

		else
			incomeSum = @income
			while i < bracket - 1
				if incomeSum > @@taxRates2013[userProvince][i][1]
					incomeTax += @@taxRates2013[userProvince][i][0]*@@taxRates2013[userProvince][i][1]
					incomeSum -= @@taxRates2013[userProvince][i][1]
					i += 1
				end
			end
			incomeTax += incomeSum*@@taxRates2013[userProvince][-1][0] - @@taxBasic2013[userProvince]*@@taxRates2013[userProvince][0][0]
		end

		return incomeTax
	end
end

andrew = Taxes.new(85000, "ON")
andrew.incomeTax("ON")
