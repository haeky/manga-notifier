require 'nokogiri'
require 'open-uri'
require 'pry'
require 'twitter'
require 'sinatra'
require 'pg'
require 'active_record'

require './config/environment'
require './models/manga'

get '/' do
  manga_parser = MangaParser.new
end

class MangaParser
  def initialize
    @root_url = 'http://www.mangapanda.com'
    @document = Nokogiri::HTML(open(@root_url))
    @settings = {}
    configure_twitter
    parse_website
    ActiveRecord::Base.connection.close
  end

  def parse_website
    mangas = Manga.all
    @document.css('a.chaptersrec').each do |link|
      *manga_name, current_chapter = link.content.split
      manga_name = manga_name.join(' ')
      stored_manga = mangas.find{ |a| a.manga_name == manga_name }
      if !stored_manga.nil? && current_chapter.to_i > stored_manga.chapter_number.to_i
        tweet_update(manga_name, stored_manga.chapter_number, current_chapter)
        stored_manga.chapter_number = current_chapter.to_i
        stored_manga.save!
      end
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
