class Category < ActiveRecord::Base
	has_and_belongs_to_many :products
	acts_as_nested_set

  	attr_accessible :depth, :lft, :link, :name, :rgt, :parent
  	validates :name, :presence => true, :uniqueness => true
	validates :link, :presence => true

	def self.next(category)
		Category.find(:first, :order => 'id ASC', :conditions => ["id > ?", category.id])
	end
end
