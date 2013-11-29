class CreateMangas < ActiveRecord::Migration
  def up
    create_table :mangas do |t|
      t.string   :manga_name
      t.integer  :chapter_number
    end
  end

  def down
  end
end
