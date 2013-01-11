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
	
	Category.all.each do |category|

		url = category.link
		products = fetch_products(url)
		products.each do |product|
			name = fetch_text(product)
			fetched_id = fetch_id(product)
			Product.create_from_category(category, fetched_id, name)
			#check
			puts "***************"
			puts "Product " + name + " is saved successfully"
			puts "***************"	
		end


		number_of_page = fetch_number_page(url)

		#save product from the second time and further, theirs links are same structure
		if (number_of_page != nil) && (number_of_page >= 2)
			(2 .. number_of_page).each do |number|
				url = "http://www.gumtree.com/flats-and-houses-for-rent/london/page" + number.to_s
				products = fetch_products(url)

				products.each do |product|
					#save product
					name = fetch_text(product)
					fetched_id = fetch_id(product)
					Product.create_from_category(category, fetched_id, name)
					#check
					puts "***************"
					puts "Product " + name + " is saved successfully"
					puts "***************"	
				end				
			end	
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
		if number_text!=""
			return number_text.to_i
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
	return item.at_css(".ad-title-text").text unless !item
end
#fetch the link in the product-tag that contains product id
def fetch_link(product)
	return product.at_css("a").attributes["href"].value unless !product
end
#fetch product id from the product tag
def fetch_id(product)
	if product
		#check
		puts "***************"
		puts "Before fetch_id of product " + fetch_text(product)
		puts "Link of product " + fetch_link(product)
		puts "***************"

		link = fetch_link(product)
		number = link.split('/').pop
		return number.to_i		
	end
	
end