class CategoriesProducts < ActiveRecord::Base
	belongs_to :product
	belongs_to :category
  attr_accessible :category, :product
end
