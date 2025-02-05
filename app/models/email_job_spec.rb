# == Schema Information
#
# Table name: email_job_specs
#
#  id                  :bigint           not null, primary key
#  attachment_pattern  :string(255)
#  bcc                 :string(255)
#  body                :text(65535)
#  cc                  :string(255)
#  csv_entries         :string(255)
#  status              :string(255)
#  subject             :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fixed_attachment_id :bigint
#  print_job_spec_id   :bigint           not null
#  smtp_account_id     :bigint
#
# Indexes
#
#  index_email_job_specs_on_fixed_attachment_id  (fixed_attachment_id)
#  index_email_job_specs_on_print_job_spec_id    (print_job_spec_id)
#  index_email_job_specs_on_smtp_account_id      (smtp_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (fixed_attachment_id => fixed_attachments.id)
#  fk_rails_...  (print_job_spec_id => print_job_specs.id)
#  fk_rails_...  (smtp_account_id => smtp_accounts.id)
#
class PrintJobSpecValidator < ActiveModel::Validator
  def validate( record )
    pjs = record.print_job_spec
    return if not pjs

    if pjs.status != PrintJobSpec::STATUS[ :finished ]
      record.errors.add :base, "Η Print Job Spec δεν έχει ολοκληρωθεί!"
      return
    end
  end
end

class EmailJobSpec < ApplicationRecord
  belongs_to :print_job_spec
  belongs_to :smtp_account, optional: true
  has_many :email_jobs
  belongs_to :fixed_attachment, optional: true

  validates_with PrintJobSpecValidator

  has_rich_text :body

  STATUS = {
    idle: "IDLE",
    waiting: "WAITING",
    retrying: "RETRYING",
    internal_error: "INTERNAL ERROR",
    sent: "SENT",
    resent: "RESENTING",
    testing: "testing",
  }

  def csv_entries_to_array
    to_return = []
    if csv_entries and csv_entries.strip != ""
      parts = csv_entries.split(",").each do |part|
        part = part.strip
        if part.index("-") 
          sub_parts = part.split("-")
          range_start = sub_parts[0].strip.to_i
          range_end = sub_parts[1].strip.to_i
          (range_start..range_end).each do |number|
            to_return << "#{number}"
          end
        else
          to_return << part
        end
      end
    else
      to_return << "all"
    end
    to_return
  end

  def csv_to_all?
    csv_entries == nil or csv_entries.strip == "" or csv_entries.strip.downcase == "all"
  end

  def get_csv_headers
    print_job_spec.get_csv_headers
  end

  def get_selected_csv_entries_with_lineno
    print_job_spec.get_selected_csv_entries_with_lineno( csv_entries_to_array )
  end

  def get_csv_entries_with_lineno
    print_job_spec.get_selected_csv_entries_with_lineno( ["all"] )
  end

  def user
    self.print_job_spec.user
  end
end
