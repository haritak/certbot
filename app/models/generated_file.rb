# == Schema Information
#
# Table name: generated_files
#
#  id                :bigint           not null, primary key
#  path              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  print_job_spec_id :bigint           not null
#
# Indexes
#
#  index_generated_files_on_path               (path) UNIQUE
#  index_generated_files_on_print_job_spec_id  (print_job_spec_id)
#
# Foreign Keys
#
#  fk_rails_...  (print_job_spec_id => print_job_specs.id)
#
class GeneratedFile < ApplicationRecord
  belongs_to :print_job_spec

  scope :odts, ->{ where("path like '%odt'") }
  scope :pdfs, ->{ where("path like '%pdf'") }
  scope :filename, ->(example) { where("path like '%#{example}%'") }

  before_destroy :delete_files

  def user
    self.print_job_spec.user
  end

  private

  def delete_files
    FileUtils.rm_f self.path if File.exist? self.path
  end
end
