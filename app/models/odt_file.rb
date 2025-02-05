# == Schema Information
#
# Table name: odt_files
#
#  id         :bigint           not null, primary key
#  filename   :string(255)
#  system     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_odt_files_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class OdtFileValidator < ActiveModel::Validator
  def validate( record )
    #physical presence of odt file
    if !record.odtfile or !record.odtfile.attached?
      record.errors.add :base, "Odt file missing or not attached."
      return
    end
  end
end

class OdtFile < ApplicationRecord
  has_one_attached :odtfile
  belongs_to :user

  scope :system, ->{ where(system: true) }

  validates :odtfile, presence: true
  validates_with OdtFileValidator
end
