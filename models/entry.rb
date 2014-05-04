class Entry < ActiveRecord::Base
  # manga_name      string
  # chapter_number  integer
  Type = { manga: 0, anime: 1 }
end
