class AddColumnSystemToOdtFile < ActiveRecord::Migration[7.0]
  def change
    add_column :odt_files, :system, :boolean, default: false
  end
end
