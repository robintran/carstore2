class Product < ActiveRecord::Base
	has_and_belongs_to_many :categories
  attr_accessible :name, :id
  validates :name, :presence => true
  validates :id, :presence => true, :uniqueness => true
end
