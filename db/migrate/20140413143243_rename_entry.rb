class RenameEntry < ActiveRecord::Migration
  def up
    rename_table :entry, :entries
  end

  def down
    rename_table :entries, :entry
  end
end
