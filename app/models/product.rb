class Product < ActiveRecord::Base
	has_and_belongs_to_many :categories
  attr_accessible :name, :fetched_id
  validates :name, :presence => true
  validates :fetched_id, :presence => true, :uniqueness => true
  
  def self.create_from_category(category, fetched_id, name)
  	category.products.create(
  		:fetched_id => fetched_id,
  		:name => name
  		) unless Product.exists?(:fetched_id => fetched_id)
  end
end


