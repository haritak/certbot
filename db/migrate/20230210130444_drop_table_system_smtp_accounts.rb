class DropTableSystemSmtpAccounts < ActiveRecord::Migration[7.0]

  def change
    remove_column :users, :smtp_account_id
    drop_table :system_smtp_accounts
  end

end
