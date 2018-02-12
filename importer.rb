require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/filters'
require 'kindle_highlights'
require 'json'

PATH_TO_HTML    = "/Users/ericfarkas/dev/speric.github.com/books/"
books_json      = JSON.parse(File.open('books.json').read)
imported_quotes = JSON.parse(File.open('completed.json').read)

kindle = KindleHighlights::Client.new(
  email_address: ENV['AMAZON_LOGIN'],
  password: ENV['AMAZON_PASSWORD'],
  mechanize_options: {
    user_agent_alias: 'iPhone'
  }
)

def formatted_content(content)
  "> #{content.squish}"
end

def unique_id_for(highlight)
  "#{highlight.asin}-#{highlight.location}"
end

books_json.each do |asin, book|
  filename   = book.fetch("filename")
  highlights = kindle.highlights_for(asin)

  if highlights.any?
    File.open("#{PATH_TO_HTML}#{filename}", 'a') do |file|
      highlights.each do |highlight|
        unique_id = unique_id_for(highlight)
        unless imported_quotes.include?(unique_id)
          file.puts(formatted_content(highlight.text))
          file.puts("\n")
          imported_quotes << unique_id
        end
      end
    end
  end
end

File.open('completed.json', 'w') { |f| f.puts imported_quotes.to_json }
