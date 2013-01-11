desc "Fetch database"
task :fetch_products => :environment do
	require 'nokogiri'
	require 'open-uri'
	require 'cgi'

	#******************************
	#product at here is only a string not an object
	#product_array is an array which contain strings not objects
	#category at here is an object
	#******************************

	@product_array = Array.new
	
	Category.all.each do |category|

		url = category.link
		products = fetch_products(url)

		#save product at the first time because it's link is different from the second and others
		save_products_into_database(products, category, @product_array)

		number_of_page = fetch_number_page(url)

		#save product from the second time and further, theirs links are same structure
		(2 .. number_of_page).each do |number|
			url = "http://www.gumtree.com/flats-and-houses-for-rent/london/page" + number.to_s
			products = fetch_products(url)
			save_products_into_database(products,category, @product_array)
		end
	end	
end

#count the number of prouct page of a category
def fetch_number_page(url)
	if url
		number_text = ""
		doc = Nokogiri::HTML(open(url))
		doc.css("#pagination a").each do |button|
			if (button.text != "Previous")&&(button.text != "Next")
				number_text = button.text
			end		
		end
		return Integer(number_text)
	end	
end

#save products of a category into database
#check if there are any same products, just add relationship between category and product
#not add new product
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

#fetch product-tags from an url of a page
def fetch_products(url)
	if url
		doc = Nokogiri::HTML(open(url))
		return doc.css(".offer-sale")
	end	
end

#fetch the name a product
def fetch_text(item)
	if item
		return item.at_css(".ad-title-text").text
	end	
end
#fetch the link in the product-tag that contains product id
def fetch_link(product)
	if product
		return product.at_css("a").attributes["href"].value
	end	
end
#fetch product id from the product tag
def fetch_id(product)
	if product
		link = fetch_link(product)
		number = link.split('/').pop
		return Integer(number)		
	end
	
end