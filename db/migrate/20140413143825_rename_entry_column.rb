class RenameEntryColumn < ActiveRecord::Migration
  def up
    rename_column :entries, :manga_name, :name
    rename_column :entries, :chapter_number, :number
  end

  def down
  end
end
