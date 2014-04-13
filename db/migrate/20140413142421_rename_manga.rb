class RenameManga < ActiveRecord::Migration
  def self.up
    rename_table :mangas, :entry
  end

  def self.down
    rename_table :entry, :mangas
  end
end
