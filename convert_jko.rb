load 'converter.rb'

converter = DoxygenConverter.new

doxygen_raw_html = "/Users/richardtolley/rails_stuff/jko_doc_site_copy/public/jko_doxygen_raw_html"
rails_path = "/Users/richardtolley/rails_stuff/jko_doc_site_copy"
converter.convert_project(doxygen_raw_html,rails_path)