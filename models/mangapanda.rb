require './models/site'

class Mangapanda < Site
  def initialize
  end

  def parse
    @document = Nokogiri::HTML(open('http://www.mangapanda.com'))
    mangas = Manga.all
    updated = []
    @document.css('a.chaptersrec').each do |link|
      *manga_name, current_chapter = link.content.split
      manga_name = manga_name.join(' ')
      stored_manga = mangas.find{|a| a.manga_name == manga_name}
      if !stored_manga.nil? && current_chapter.to_i > stored_manga.chapter_number.to_i
        if block_given?
          yield(stored_manga, current_chapter)
        end
      end
    end
  end
end
