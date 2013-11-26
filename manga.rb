require 'nokogiri'
require 'open-uri'
require 'pry'

class MangaParser
  def initialize
    @root_url = 'http://www.mangapanda.com'
    @settings_path = 'manga.conf'
    @document = Nokogiri::HTML(open(@root_url))
    @settings = {}
    parse_settings
    parse_website
    rewrite_settings
  end

  def parse_settings
    File.open(@settings_path, "r") do |file|
      while (line = file.gets)
        content = line.chomp.split(';')
        current_chapter = content.length > 1 ? content.pop : 0
        manga_name = content.join(' ')
        @settings[manga_name] = current_chapter
      end
    end
  end

  def parse_website
    @document.css('a.chaptersrec').each do |link|
      content = link.content.split
      current_chapter = content.pop
      manga_name = content.join(' ')
      if @settings.has_key?(manga_name) && current_chapter.to_i > @settings[manga_name].to_i
        @settings[manga_name] = current_chapter
      end
    end
  end

  def rewrite_settings
    output = ""
    File.open(@settings_path, 'w') do |f|
      @settings.each do |setting|
        manga_name = setting[0]
        current_chapter = setting[1]
        output << "#{manga_name};#{current_chapter}\n"
      end
      f.puts output
    end
  end
end

manga_parser = MangaParser.new
