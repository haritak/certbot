class RenameColumnSystemSmtpAccountToSelectedSmtpAccountOfUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :system_smtp_account_id, :smtp_account_id
  end
end
