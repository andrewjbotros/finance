class Profile
	attr_accessor :id,:first_name,:last_name,:email,:age,:sex,:province,:income

	def initialize (id, first_name, last_name, email, age, sex, province, income)
		@id = id
		@first_name = first_name
		@last_name = last_name
		@email = email
		@age = age
		@sex = sex
		@province = province
		@income = income
	end
end