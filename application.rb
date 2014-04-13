require 'nokogiri'
require 'open-uri'
require 'pry'
require 'twitter'
require 'sinatra'
require 'pg'
require 'active_record'

require './config/environment'
require './models/entry'
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
      website.parse do |stored_entry, updated_number|
        tweet_update(stored_entry.name, stored_entry.number, updated_number)
        stored_entry.update_attribute :number, updated_number.to_i
      end
    end
  end

  def tweet_update(name, old_number, new_number)
    output = "#{name} is now out ! #{old_number} -> #{new_number}"
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
