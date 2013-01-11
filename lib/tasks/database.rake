desc "Fetch database"
task :fetch_database => :environment do
	require 'nokogiri'
	require 'open-uri'
	require 'cgi'

	finish = false
	current_category = nil
	url = "http://www.gumtree.com/all/london"

	while !finish	

		url = current_category.link unless !current_category
		category_tags = fetch_category_tags(url)
		child_category_tags = fetch_child_category_tags(url)

		#save categories into database
		category_tags.each do |category_tag|
			if (!is_child_tag(category_tag, child_category_tags)) && (fetch_text(category_tag) != "See full list") 
				save_category_into_database(category_tag, current_category)
			end
		end

		#check
		puts "***************"
		puts ">>>>> Current Category before if : " + current_category.name unless !current_category
		puts "***************"	

		if current_category
			current_category = Category.next(current_category)
			break unless current_category
		else
			current_category = Category.first unless current_category
		end

		#check
		puts "***************"
		puts ">>>>> Current Category after if : " + current_category.name
		puts "***************"		

		while check_number_tag(current_category.link) == 0
			#check
			puts "***************"
			puts ">>>>> Need to change Category: " + current_category.name
			puts "***************"	

			current_category = Category.next(current_category)
			finish = true unless current_category

			#check
			puts "***************"
			puts ">>>>> Current Category: " + current_category.name
			puts "***************"	
		end
		
		#check
		puts "***************"
		puts ">>>>> Final Current Category: " + current_category.name
		puts "***************"		

		# finish = true
	end

end

def check_number_tag(url)
	category_tags = fetch_category_tags(url)
	#check
	puts "***************"
	puts ">>>>> Number of category tag: " + category_tags.count.to_s
	puts "***************"	

	return category_tags.count
end

#save a category into database
#check if it has parent
def save_category_into_database(category_tag, parent_category)
	name = fetch_text(category_tag)
	link = fetch_url(category_tag)

	Category.create(
		:name => name,
		:parent => parent_category,
		:link => link		
		)
	#check
	puts "***************"
	puts "Category " + name + " is saved successfully"
	puts "***************"
end

#check a category tag is a child category tag or not
def is_child_tag(category_tag, child_category_tags)
	if (category_tag!=nil)&&(child_category_tags!=nil)
		is_child = false
		child_category_tags.each do |child_category_tag|
			if fetch_text(child_category_tag) == fetch_text(category_tag)
				is_child = true
				break
			end
		end
		return is_child
	end	
end

#fetch name of category from tag
def fetch_text(item)
	return item.at_css("a").text unless !item
end

#fetch all child category tags from a website
def fetch_child_category_tags(url)
	if url
		doc = Nokogiri::HTML(open(url))
		return doc.css(".active .js-show .js-show")
	end	
end

#fetch all category tags from a website
def fetch_category_tags(url)
	if url
		doc = Nokogiri::HTML(open(url))
		return doc.css("#category-tree .active .js-show")	
	end	
end

#fetch url from a category tag
#that will redirect to show it's products and it's children categories
def fetch_url(item)
	if !item
		return "http://www.gumtree.com/all/london"
	else
		return item.at_css("a").attributes["href"].value
	end
end