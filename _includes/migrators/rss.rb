# Custom version of Jekyll's RSS migrator.
#
# Usage:
#   (URL)
#   ruby -r '_includes/migrators/rss.rb' -e "Jekyll::MigrateRSS.process('http://yourdomain.com/your-favorite-feed.xml')"
#
#   (Local file)
#   ruby -r '_includes/migrators/rss.rb' -e "Jekyll::MigrateRSS.process('./somefile/on/your/computer.xml')"

require 'rubygems'
require 'rss/1.0'
require 'rss/2.0'
require 'html2markdown'
require 'open-uri'
require 'fileutils'
require 'yaml'

module Jekyll
  module MigrateRSS

    # The `source` argument may be a URL or a local file.
    def self.process(source)
      content = ""
      open(source) { |s| content = s.read }
      rss = RSS::Parser.parse(content, false)

      raise "There doesn't appear to be any RSS items at the source (#{source}) provided." unless rss

      rss.items.each do |item|
        formatted_date = item.date.strftime('%Y-%m-%d')
        post_name = item.title.split(%r{ |!|/|:|&|-|$|,}).map { |i| i.downcase if i != '' }.compact.join('-')
        name = "#{formatted_date}-#{post_name}"
        content = HTMLPage.new :contents => item.description

        header = {
          'layout' => 'post',
          'title' => item.title
        }

        File.open("_posts/#{name}.md", "w") do |f|
          f.puts header.to_yaml
          f.puts "---\n"
          f.puts content.markdown
        end
      end
    end
  end
end
