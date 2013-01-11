class Product < ActiveRecord::Base
	has_and_belongs_to_many :categories
  attr_accessible :name, :id
end
