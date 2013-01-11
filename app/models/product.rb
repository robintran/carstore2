class Product < ActiveRecord::Base
	has_and_belongs_to_many :categories, :join_table => "categories_products"
  attr_accessible :name, :id
  validates :name, :presence => true
  validates :id, :presence => true, :uniqueness => true

  def self.create_from_category(category, id, name)
  	category.products.create(
  		:id => id,
  		:name => name
  		) unless Product.exists?(:id => id)
  end
end


