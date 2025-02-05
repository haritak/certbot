# == Schema Information
#
# Table name: self_service_print_job_specs
#
#  id                                                                           :bigint           not null, primary key
#  active(Whether accepting clients or not)                                     :boolean          default(FALSE)
#  banner                                                                       :string(255)      default("banner.jpg")
#  css                                                                          :string(255)      default("default.css")
#  direct_download                                                              :boolean          default(TRUE)
#  field_names                                                                  :text(65535)
#  gdpr                                                                         :string(255)      default("gdpr.html")
#  secret_url_part(Used to create a url to be given to clients)                 :string(255)
#  send_email                                                                   :boolean          default(TRUE)
#  title                                                                        :string(255)      not null
#  validate_client_email(Whether to verify that the email exists into csv file) :boolean          default(FALSE)
#  created_at                                                                   :datetime         not null
#  updated_at                                                                   :datetime         not null
#  print_job_spec_id                                                            :bigint           not null
#  smtp_account_id                                                              :bigint
#
# Indexes
#
#  index_self_service_print_job_specs_on_print_job_spec_id  (print_job_spec_id)
#  index_self_service_print_job_specs_on_secret_url_part    (secret_url_part)
#  index_self_service_print_job_specs_on_smtp_account_id    (smtp_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (print_job_spec_id => print_job_specs.id)
#  fk_rails_...  (smtp_account_id => smtp_accounts.id)
#
require "test_helper"

class SelfServicePrintJobSpecTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
