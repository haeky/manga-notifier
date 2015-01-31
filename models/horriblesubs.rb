require './models/site'

class HorribleSubs < Site
  def parse
    document = Nokogiri::HTML(open('http://horriblesubs.info/lib/latest.php'))
    type = Entry::TYPE[:anime]
    entries = Entry.all
    updated = []
    document.css('div.episode > text()').each do |link|
      date, *anime_name, separator, current_episode = link.content.split
      anime_name = anime_name.join(' ')
      stored_anime = entries.find{|e| e.name == anime_name && e.entry_type == type}
      if !stored_anime.nil? && current_episode.to_i > stored_anime.number.to_i
        if block_given?
          yield(stored_anime, current_episode.to_i)
        end
      end
    end
  end
end
