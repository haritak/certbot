# == Schema Information
#
# Table name: csv_files
#
#  id         :bigint           not null, primary key
#  filename   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_csv_files_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class CsvFileValidator < ActiveModel::Validator
  def validate( record )

    #presence of csv file
    if !record.csvfile or !record.csvfile.attached?
      record.errors.add :base, "Csv file missing or not attached."
      return
    end

  end
end
class CsvFile < ApplicationRecord
  has_one_attached :csvfile
  belongs_to :user

  validates :csvfile, presence: true
  validates_with CsvFileValidator
end
