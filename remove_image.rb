require 'nokogiri'


def remove_image_tag_from_file file_path

	f = File.open file_path,"r"
	out_buffer = ""
	lines = f.readlines
	in_titlearea_div = false
	div_depth = 0

	lines.each do |line|

		if line.match /<div id="titlearea">/
			in_titlearea_div = true
		end 
		
		if in_titlearea_div

			if line.match /<div/
				div_depth += 1
			end

			if line.match /<\/div>/
				if div_depth == 1
					in_titlearea_div = false
				else
					div_depth -= 1
				end
			end
		else
			out_buffer << line
		end
	end

	f.close
	out_f = File.open file_path,"w"
	out_f.write out_buffer
end

remove_image_tag_from_file "image_remover_test.html"
