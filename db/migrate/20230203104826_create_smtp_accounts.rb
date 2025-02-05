class CreateSmtpAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :smtp_accounts do |t|
      t.references :user, null: false, foreign_key: true, comment: "Owner of this entry"
      t.string :description
      t.string :from
      t.string :server
      t.integer :port
      t.string :username, limit: 500, comment: "Extra large for encrypted content"
      t.string :password, limit: 500, comment: "Extra large for encrypted content"
      t.string :type, comment: "STI (Single Table Inheritance for SmtpAccount and SystemSmtpAccount)"

      t.timestamps
    end
  end
end
