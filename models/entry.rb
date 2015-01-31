class Entry < ActiveRecord::Base
  # manga_name      string
  # chapter_number  integer
  TYPE = { manga: 0, anime: 1 }
end
