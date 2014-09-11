
require 'nokogiri'

def tidy_doc_html page_page

	puts "File is #{page_page}"

	in_file = File.open "/Users/richardtolley/rails_stuff/jko_doc_site_copy/app/views/doxygen_docs/#{page_page}","r"
	html_doc = Nokogiri::HTML::Document.parse in_file
	in_file.close

	html_doc.css("div").each { |div| div.remove if div["id"] == "titlearea" }

	out_str = html_doc.to_s

	doc_type = "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">"

	out_str.gsub!(doc_type,"")

	tags_to_remove = ["html","body"]

	tags_to_remove.each do |tag|

		out_str.gsub!("<#{tag}>","")
		out_str.gsub!("</#{tag}>","")
	end

	out_file = File.open "/Users/richardtolley/rails_stuff/jko_doc_site_copy/app/views/doxygen_docs/#{page_page}","w"
	out_file.write out_str



end

html_files_in_public = IO.popen("ls /Users/richardtolley/rails_stuff/jko_doc_site_copy/app/views/doxygen_docs")

html_files_in_public.each do |file| 

	file.chomp!
	tidy_doc_html(file) if file.match /\.html\.erb$/ 

end










