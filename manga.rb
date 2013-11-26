require 'nokogiri'
require 'open-uri'
require 'pry'
require 'twitter'

class MangaParser
  def initialize
    @root_url = 'http://www.mangapanda.com'
    @settings_path = 'manga.conf'
    @document = Nokogiri::HTML(open(@root_url))
    @settings = {}
    configure_twitter
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
        tweet_update(manga_name, @settings[manga_name], current_chapter)
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

  def tweet_update(manga_name, old_chapter, new_chapter)
    @client.update("#{manga_name} is now out ! #{old_chapter} -> #{new_chapter}")
  end

  def configure_twitter
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end
end

manga_parser = MangaParser.new
