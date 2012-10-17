# encoding: utf-8

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

    # Make a suitable file name from a title by removing whitespace and special characters.
    def self.filename(title)
      title.split(%r{ |!|/|:|&|-|$|,|\?|%|\(|\)}).map { |i| i.downcase if i != '' }.compact.join('-')
    end

    # Convert to ascii and replace non-ascii letters.
    def self.transliterate(input)
      replacements = {
        'å' => 'a',
        'ä' => 'a',
        'â' => 'a',
        'á' => 'a',
        'à' => 'a',
        'ç' => 'c',
        'é' => 'e',
        'è' => 'e',
        'ê' => 'e',
        'ë' => 'e',
        'ï' => 'i',
        'í' => 'i',
        'ì' => 'i',
        'ö' => 'o',
        'ó' => 'o',
        'ò' => 'o',
        'ô' => 'o',
        'ü' => 'u',
        'æ' => 'ae',
        'œ' => 'oe',
        'ß' => 'ss',
      }
      input.encode! Encoding::ASCII, :fallback => replacements
    end

    # The `source` argument may be a URL or a local file.
    def self.process(source)
      content = ""
      open(source) { |s| content = s.read }
      rss = RSS::Parser.parse(content, false)

      raise "There doesn't appear to be any RSS items at the source (#{source}) provided." unless rss

      rss.items.each do |item|

        post_name = self.filename(item.title)
        formatted_date = item.date.strftime('%Y-%m-%d')
        file_name = "#{formatted_date}-#{post_name}"

        permalink = self.transliterate(post_name).sub('?', '') # Remove remaining question marks.

        content = HTMLPage.new :contents => item.description

        header = {
          'layout' => 'post',
          'title' => item.title.gsub(/&(?!amp;)/i, '&amp;'),
          'permalink' => permalink
        }

        File.open("_posts/#{file_name}.md", "w") do |f|
          f.puts header.to_yaml
          f.puts "---\n"
          f.puts content.markdown
        end
      end
    end
  end
end
