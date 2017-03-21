class Program < ApplicationRecord

	has_many :lines, :dependent => :destroy
	has_many :tests, :dependent => :destroy

	scope :sorted, lambda {order("position")}
	scope :visible, lambda{where(:visible => true)}
	
end
