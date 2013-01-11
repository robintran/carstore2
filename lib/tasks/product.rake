desc "Fetch database"
task :fetch_products => :environment do
	require 'nokogiri'
	require 'open-uri'
	require 'cgi'

	@product_array = Array.new

	categories = Category.where(:depth => 0)
	
	categories.each do |category|

		url = category.link
		products = fetch_products(url)

		save_products_into_database(products, category, @product_array)

		number_of_page = fetch_number_page(url)

		(2 .. number_of_page).each do |number|
			url = "http://www.gumtree.com/flats-and-houses-for-rent/london/page" + number.to_s
			products = fetch_products(url)
			save_products_into_database(products,category, @product_array)
		end
	end	
end

def fetch_number_page(url)
	number_text = ""
	doc = Nokogiri::HTML(open(url))
	doc.css("#pagination a").each do |button|
		if (button.text != "Previous")&&(button.text != "Next")
			number_text = button.text
		end		
	end
	return Integer(number_text)
end

def save_products_into_database(products, category, product_array)
	products.each do |product|
		flag = false
		product_array.each do |item|
			if fetch_id(item) == fetch_id(product)
				flag = true
				break
			end
		end
		if flag
			number = fetch_id(product)
			product = Product.find_by_id(number)
			CategoriesProducts.create(
				:product => product,
				:category => category
				)

			#check
			puts "***************"
			puts "Relationship between Category " + category.id.to_s + " Product " + product.id.to_s + " is saved successfully"
			puts "***************"
		else
			name = fetch_text(product)
			number = fetch_id(product)
			category.products.create(
				:id => number,
				:name => name
				)

			#check
			puts "***************"
			puts "Product " + name + " is saved successfully"
			puts "***************"

			product_array[product_array.count] = product
		end		
	end		
end

def fetch_products(url)
	doc = Nokogiri::HTML(open(url))
	return doc.css(".offer-sale")
end

def fetch_text(item)
	if item
		return item.at_css(".ad-title-text").text
	end	
end
def fetch_link(product)
	if product
		return product.at_css("a").attributes["href"].value
	end	
end
def fetch_id(product)
	if product
		link = fetch_link(product)
		number = link.split('/').pop
		return Integer(number)		
	end
	
end