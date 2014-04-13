class Entry < ActiveRecord::Base
  # manga_name      string
  # chapter_number  integer
  TYPE = { manga: 0, anime: 1 }

  def type
    TYPE.key(read_attribute(:type))
  end

  def type=(t)
    write_attribute(:type, TYPE[t])
  end
end
