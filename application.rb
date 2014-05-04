require 'nokogiri'
require 'open-uri'
require 'twitter'
require 'sinatra'
require 'pg'
require 'active_record'
require 'pry'

require './config/environment'
require './models/entry'
require './models/mangapanda'

get '/' do
  Entry.all.to_json
end

Thread.new do
  parser = WebParser.new
  while true do
    parser.parse_websites
    sleep 120
  end
end

class WebParser
  def initialize
    configure_twitter
  end

  def close
    ActiveRecord::Base.connection.close
  end

  def parse_websites
    puts "[#{Time.now()}] Initializing a new parsing"
    websites = [Mangapanda.new]
    for website in websites
      website.parse do |stored_entry, updated_number|
        tweet_update(stored_entry.name, stored_entry.number, updated_number)
        update_database_entry(stored_entry, updated_number)
      end
    end
  end

  def tweet_update(name, old_number, new_number)
    output = "#{name} is now out ! #{old_number} -> #{new_number}"
    if Sinatra::Base.production?
      @client.update(output)
    else
      puts "[#{Time.now()}] #{output}"
    end
  end

  def update_database_entry(stored_entry, updated_number)
    stored_entry.update_attribute :number, updated_number.to_i if Sinatra::Base.production?
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
