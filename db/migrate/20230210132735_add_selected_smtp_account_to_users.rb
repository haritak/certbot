class AddSelectedSmtpAccountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :smtp_account, foreign_key: true
  end
end
