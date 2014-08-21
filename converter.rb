
class DoxygenConverter

	def convert_project(project_directory_path,rails_root_path)
		@project_directory_path = project_directory_path
		@rails_root_path = rails_root_path
		if @project_directory_path
			find_images_and_move_to_assets
			find_stylesheets_and_move_to_assets
			find_javascripts_and_move_to_assets
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
		html_files = find_paths_with_extension(["html"],@project_directory_path)

	end



end

converter = DoxygenConverter.new

converter.convert_project("/Users/richardtolley/rails_stuff/jko_doc_site_copy/public/ios_doxygen_html","/Users/richardtolley/rails_stuff/jko_doc_site_copy")


