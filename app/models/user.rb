# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE)
#  admin                  :boolean
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string(255)
#  unlock_token           :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  smtp_account_id        :bigint
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_smtp_account_id       (smtp_account_id)
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (smtp_account_id => smtp_accounts.id)
#
class User < ApplicationRecord
  has_many :smtp_accounts
  has_many :system_smtp_accounts
  belongs_to :smtp_account, optional: true

  # https://github.com/heartcombo/devise#activejob-integration
  def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  # https://github.com/heartcombo/devise/wiki/How-To:-Require-admin-to-activate-account-before-sign_in
  def active_for_authentication? 
      super && (admin? or activated?)
  end 

  def inactive_message 
      (admin? or activated?) ? super : :not_activated
  end

  def is_admin?
    admin
  end

  def no_smtp_account?
    smtp_account == nil
  end

  def custom_smtp_account?
    smtp_account&.custom_smtp_account?
  end

end
