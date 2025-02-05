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
require "test_helper"

class EmailJobSpecTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
