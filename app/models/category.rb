class Category < ActiveRecord::Base
	has_and_belongs_to_many :products
	acts_as_nested_set
  attr_accessible :depth, :lft, :link, :name, :rgt
end
