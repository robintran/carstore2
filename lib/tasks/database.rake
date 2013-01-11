desc "Fetch database"
task :fetch_database => :environment do
	require 'nokogiri'
	require 'open-uri'
	require 'cgi'

	finish = false
	current_category_tag = nil # is a string
	category_tags_array = Array.new
	category_tag_flag = -1

	while !finish
		url = fetch_url(current_category_tag)
		category_tags = fetch_category_tags(url)
		child_category_tags = fetch_child_category_tags(url)

		#save categories into database
		category_tags.each do |category_tag|
			if (!is_child_tag(category_tag, child_category_tags)) && (fetch_text(category_tag) != "See full list") 
				save_category_into_database(category_tag, current_category_tag)

				#save category tags into array
				category_tag_flag += 1
				category_tags_array[category_tag_flag] = category_tag

				#check
				puts "***************"
				puts "Category tags array has an item " + category_tag_flag.to_s + " - " + fetch_text(category_tag)
				puts "***************"
			end	
		end

		#check category tags array is empty?
		if category_tag_flag == -1
			finish = true
		end

		#check
		puts "***************"
		puts "Finish is " + finish.to_s
		puts "***************"

		#update current parent
		check_flag = true
		while check_flag
			if category_tag_flag == -1
				finish = true
				check_flag = false
			end

			last_category_tag = category_tags_array.pop
			category_tag_flag = category_tag_flag - 1

			if have_children_tag(last_category_tag)
				current_category_tag = last_category_tag
				#check
				puts "***************"
				puts fetch_text(current_category_tag)
				puts "***************"
				check_flag = false				
			end

			#check
			puts "***************"
			puts "Finish " + finish.to_s
			puts "check_flag" + check_flag.to_s
			puts "***************"

		end

		#exist while loop
		# finish = true
	end

end

def have_children_tag(category_tag)
	have_child = false
	url = fetch_url(category_tag)
	if fetch_category_tags(url)
		have_child = true
	end
	return have_child
end

def save_category_into_database(category_tag, parent_category_tag)
	name = fetch_text(category_tag)
	parent_category = nil
	link = fetch_url(category_tag)

	if parent_category_tag
		parent_category_name = fetch_text(parent_category_tag)
		parent_category = Category.find_by_name(parent_category_name)	
	end	

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

def is_child_tag(category_tag, child_category_tags)
	is_child = false
	child_category_tags.each do |child_category_tag|
		if fetch_text(child_category_tag) == fetch_text(category_tag)
			is_child = true
			break
		end
	end
	return is_child
end

def fetch_text(item)
	return item.at_css("a").text
end

def fetch_child_category_tags(url)
	doc = Nokogiri::HTML(open(url))
	return doc.css(".active .js-show .js-show")
end

def fetch_category_tags(url)
	doc = Nokogiri::HTML(open(url))
	return doc.css("#category-tree .active .js-show")
end

def fetch_url(item)
	if !item
		return "http://www.gumtree.com/all/london"
	else
		return item.at_css("a").attributes["href"].value
	end
end