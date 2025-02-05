class AddFixedAttachmentToEmailJobSpecs < ActiveRecord::Migration[7.0]
  def change
    add_reference :email_job_specs, :fixed_attachment, null: true, foreign_key: true
  end
end
