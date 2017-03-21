class AdminUser < ApplicationRecord

	has_secure_password
	has_many :tests, :dependent => :destroy

	scope :sorted, lambda {order('superuser DESC, year DESC,section, roll_number, first_name, last_name')}

	def name
		"#{first_name} #{last_name}"
	end
	
end
