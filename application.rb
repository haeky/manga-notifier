require 'nokogiri'
require 'open-uri'
require 'pry'
require 'twitter'
require 'sinatra'
require 'pg'
require 'active_record'

require './config/environment'
require './models/manga'
require './models/mangapanda'

get '/' do
  manga_parser = MangaParser.new
end

class MangaParser
  def initialize
    configure_twitter
    parse_websites
    ActiveRecord::Base.connection.close
  end

  def parse_websites
    websites = [Mangapanda.new]
    for website in websites
      website.parse do |stored_manga, updated_chapter|
        tweet_update(stored_manga.manga_name, stored_manga.chapter_number, updated_chapter)
        stored_manga.update_attribute :chapter_number, updated_chapter.to_i
      end
    end
  end

  def tweet_update(manga_name, old_chapter, new_chapter)
    binding.pry
    output = "#{manga_name} is now out ! #{old_chapter} -> #{new_chapter}"
    if Sinatra::Base.production?
      @client.update(output)
    else
      puts output
    end
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
