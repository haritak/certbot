# == Schema Information
#
# Table name: self_service_generated_files
#
#  id                        :bigint           not null, primary key
#  path                      :string(500)
#  status                    :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  self_service_print_job_id :bigint           not null
#
# Indexes
#
#  index_self_service_generated_files_on_path                       (path)
#  index_self_service_generated_files_on_self_service_print_job_id  (self_service_print_job_id)
#  index_self_service_generated_files_on_status                     (status)
#
# Foreign Keys
#
#  fk_rails_...  (self_service_print_job_id => self_service_print_jobs.id)
#
class SelfServiceGeneratedFile < ApplicationRecord
  STATUS = {
    idle: "IDLE",
    preparing_1: "PREPARING STAGE 1",
    preparing_2: "PREPARING STAGE 2",
    internal_error: "INTERNAL ERROR",
    created: "CREATED",
    testing: "testing",
  }

  scope :failed,  ->{ where.not( status: SelfServiceGeneratedFile::STATUS[:created] ) }
  scope :odts, ->{ where("path like '%odt'") }
  scope :pdfs, ->{ where("path like '%pdf'") }

  belongs_to :self_service_print_job

  before_destroy :delete_files

  def self_service_print_job_spec
    self.self_service_print_job.self_service_print_job_spec
  end

  def user
    self.self_service_print_job.user
  end

  private

  def delete_files
    FileUtils.rm_f self.path if File.exist? self.path
  end
end
