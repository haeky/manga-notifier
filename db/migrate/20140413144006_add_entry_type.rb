class AddEntryType < ActiveRecord::Migration
  def up
    add_column :entries, :entry_type, :integer, :default => 0
  end

  def down
    remove_column :entries, :type
  end
end
