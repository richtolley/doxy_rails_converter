#!/usr/bin/env ruby

require 'nokogiri'

class DoxygenConverter

	def convert_project(project_directory_path,rails_root_path,doxy_controller_name = "doxygen_docs")
		@project_directory_path = project_directory_path
		@rails_root_path = rails_root_path
		@read_erb_file_to_route_map
		@doxy_controller_name = doxy_controller_name

		if @project_directory_path
			
			find_images_and_move_to_assets
			find_stylesheets_and_move_to_assets
			find_javascripts_and_move_to_assets
			@html_file_to_route_map = generate_routes_for_assets
			replace_link_tags @html_file_to_route_map
		end
	end

	def find_paths_with_extension(extensions_to_find,dir_to_search)
		all_files = IO.popen("ls #{dir_to_search}")
		paths = all_files.inject([]) do |acc,it|
			extensions_to_find.each { |ext| acc << it if it.match(/\.#{ext}$/) }
			acc
		end
	end

	def find_paths_with_extension_and_move_to_dir(file_extensions_to_find,dir_to_search,dir_to_move_file_to)
		paths = find_paths_with_extension(file_extensions_to_find,dir_to_search)
		paths.each { |path| system "mv '#{dir_to_search}/#{path.chomp}' '#{dir_to_move_file_to}/#{path.chomp}'" }
	end

	def find_images_and_move_to_assets
		image_assets_path = "#{@rails_root_path}/app/assets/images"
		find_paths_with_extension_and_move_to_dir(["png","jpg","jpeg"],@project_directory_path,image_assets_path)
	end

	def find_stylesheets_and_move_to_assets
		image_assets_path = "#{@rails_root_path}/app/assets/stylesheets"
		find_paths_with_extension_and_move_to_dir(["css","scss"],@project_directory_path,image_assets_path)
	end

	def find_javascripts_and_move_to_assets
		image_assets_path = "#{@rails_root_path}/app/assets/javascripts"
		find_paths_with_extension_and_move_to_dir(["js"],@project_directory_path,image_assets_path)
	end

	def generate_routes_for_assets
		html_file_to_route_map = {}
		html_files = find_paths_with_extension(["html"],@project_directory_path)
		path_names = html_files.inject([]) do |acc,it| 
			file_name_without_extension = it.gsub("\.html","")
			file_name_without_extension = file_name_without_extension.gsub("-","_").chomp #Rails controller method names should not have a - in them
			acc << file_name_without_extension
			html_file_to_route_map[it.chomp] = "#{file_name_without_extension}"
			acc
		end

		path_names_str = path_names.inject("") { |acc,it| acc << " #{it}" }		
		rails_generate_command_string = "rails generate controller doxygen_docs #{path_names_str}"
		Dir.chdir(@rails_root_path){ system rails_generate_command_string } 	

		html_file_to_route_map		
	end

	def replace_link_tags(html_file_to_route_map)
		html_files = find_paths_with_extension(["html"],@project_directory_path)
		html_files.each { |file| railsify_html_file file,html_file_to_route_map }


		
	end

	def remove_title_table file_name

		
		in_file = File.open "#{@rails_root_path}/app/views/#{@doxy_controller_name}/#{file_name.chomp}.erb","r"

		html_doc = Nokogiri::HTML::Document.parse in_file
		in_file.close

		html_doc.css("div").each { |div| div.remove if div["id"] == "titlearea" }
		html_doc.css("div").each { |div| div.remove if div["id"] == "MSearchBox" }
		html_doc.css("div").each { |div| div.remove if div["id"] == "MSearchSelectWindow" }
		html_doc.css("div").each { |div| div.remove if div["id"] == "MSearchResultsWindow" }
		out_file = File.open "#{@rails_root_path}/app/views/#{@doxy_controller_name}/#{file_name.chomp}.erb","w"
		out_file.write html_doc.to_s
		out_file.close
	end

	def railsify_html_file file_name,html_file_to_route_map

		puts "#{@project_directory_path}/#{file_name}"

		#Copy contents of HTML file in public directory into a newly created html.erb file in the doxygen_docs subdir
		#of views

		orig_html_file = File.open("#{@project_directory_path}/#{file_name.chomp}","r")

		erb_file_path = "#{@rails_root_path}/app/views/#{@doxy_controller_name}/#{file_name.chomp}.erb"

		orig_erb_file = File.open(erb_file_path,"w")
		orig_erb_file.write orig_html_file.read
		orig_erb_file.close
		orig_html_file.close

		#Remove the unwanted title table that doxygen puts at the top of each page

		remove_title_table file_name
		read_erb_file =  File.open(erb_file_path,"r")
		
		in_body = false

		file_output_string = ""

		read_erb_file.each do |line|

			if line.match("<body>")
				in_body = true
				next 
			end

			if in_body

				if line.match("</body>")
					in_body = false
				else
					
					output_string = line
					m = line.match(/(a .*href=\")(.*)\"/) #Find and replace anchor tags hrefs with rails erb tags pointing to routes just generated

					if m
						tag_start,file_name = m.captures
						
						rails_path_for_link = html_file_to_route_map[file_name]
						if rails_path_for_link
							output_string = line.gsub("\"#{file_name}\"","<%= \"#{rails_path_for_link}\" %>")
							
						end
					end

					image_match = line.match(/<img.*\/>|<\/img>|<img.*/) #Doxygen output seems to have some unclosed image tags, hence 3rd group

					if image_match
						puts "Match was #{image_match}"
						
						tag = Nokogiri::XML::Document.parse(image_match.to_s)

						puts tag.root["src"]


						output_string = "<%= image_tag('#{tag.root["src"]}') %>"

						tag.root.attributes.each_pair do |k,v|
							puts "Key is #{k}, value is #{v}"
						end

					end

					file_output_string << output_string

				end

			end

		end


		write_erb_file = File.open(erb_file_path,"w")
		write_erb_file.write file_output_string

	end


end

converter = DoxygenConverter.new



converter.convert_project("/Users/richardtolley/rails_stuff/jko_doc_site_copy/public/ios_doxygen_html","/Users/richardtolley/rails_stuff/jko_doc_site_copy")


