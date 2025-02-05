class CreateSystemSmtpAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :system_smtp_accounts do |t|
      t.string :description
      t.string :from
      t.string :server
      t.integer :port
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
