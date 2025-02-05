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
class PresentationFilesValidator < ActiveModel::Validator
  def validate(record)
    if not record.css or record.css.strip == ""
      record.errors.add(:base, "Δεν έχει οριστεί css αρχείο") 
    else
      if not File.exist? Rails.root.join("app/assets/stylesheets", record.css)
        record.errors.add(:base, "Δεν υπάρχει το αρχείο css #{record.css}. Παρακαλώ ζητείστε να ανέβει στον server στον φάκελο assets.")
      end
    end
    if not record.banner or record.css.strip == ""
      record.errors.add(:base, "Δεν έχει οριστεί banner αρχείο")
    else
      if not File.exist? Rails.root.join("public", record.banner)
        record.errors.add(:base, "Δεν υπάρχει το αρχείο banner #{record.banner}. Παρακαλώ ζητείστε να ανέβει στον server στον φάκελο public.")
      end
    end
    if not record.gdpr or record.gdpr == ""
      record.errors.add(:base, "Δεν έχει οριστεί gdpr αρχείο")
      if not File.exist? Rails.root.join("public", record.gdpr)
        record.errors.add(:base, "Δεν υπάρχει το αρχείο gdpr #{record.gdpr}. Παρακαλώ ζητείστε να ανέβει στον server στον φάκελο public.")
      end
    end
  end
end

class JsonValidator < ActiveModel::Validator
  def validate( record )

    parsed = nil
    begin
      parsed = JSON.parse record.field_names
    rescue => e
      record.errors.add :base, "Μη αποδεκτή JSON"
      return
    end

    email_found = false
    gender_found = false
    parsed.each_with_index do |entry, idx|
      idx += 1
      if not entry.keys.include? "view_name"
        record.errors.add :base, "Δεν υπάρχει η τιμή view_name στην γραμμή #{idx}"
      end
      if not entry.keys.include? "odt_name"
        record.errors.add :base, "Δεν υπάρχει η τιμή odt_name στην γραμμή #{idx}"
      end
      entry_value = entry[ "odt_name" ]
      if entry_value !~ /\A[A-Ζ_]+\Z/
        record.errors.add :base, "Μη αποδεκτή τιμή για το odt_name στην γραμμή #{idx}"
      end

      email_found = true if entry_value =~ /\Aemail\Z/i
      gender_found = true if entry_value =~ /\Agender(_acc|_ignore)?\Z/i #needs to account for gender, gender_ignore and gender_acc
    end
    record.errors.add( :base, "Δεν υπάρχει πεδίο email" ) if not email_found
    record.errors.add( :base, "Δεν υπάρχει πεδίο gender ... " ) if not gender_found

  end
end

class SmtpAccountValidator < ActiveModel::Validator
  def validate( record )
    if record.send_email
      if !record.smtp_account or !record.smtp_account.is_a?(SystemSmtpAccount)
        record.errors.add( :base,
                           "Για την αποστολή email πρέπει να επιλεγεί λογαριασμός SMTP." )
      end
    end

    if !record.send_email and !record.direct_download
        record.errors.add( :base,
                          "Δεν υπάρχει τρόπος παραλαβής. Παρακαλώ επιλέξτε άμεσο κατέβασμα ή/και αποστολή email." )
    end

  end
end

class SelfServicePrintJobSpec < ApplicationRecord
  belongs_to :print_job_spec
  belongs_to :smtp_account, optional: true
  has_many :self_service_print_jobs
  has_many :self_service_generated_files, 
    through: :self_service_print_jobs
  has_many :self_generated_emails

  validates_with JsonValidator
  validates_with SmtpAccountValidator
  validates_with PresentationFilesValidator

  def user
    self.print_job_spec.user
  end

  def to_s
    "[#{self.print_job_spec.id}] #{user.email}"
  end

  def initialize_with_defaults
    self.title = "Βεβαίωση χωρίς τίτλο" 
    self.field_names = [ 
      {view_name: "Φύλο",        odt_name: "GENDER"}, 
      {view_name: "Όνομα",       odt_name: "FIRST_NAME"},
      {view_name: "Επώνυμο",     odt_name: "LAST_NAME"},
      {view_name: "Πατρώνυμο",   odt_name: "FATHER_NAME"},
      {view_name: "Μητρώνυμο",   odt_name: "MOTHER_NAME"},
      {view_name: "email",       odt_name: "EMAIL"},
    ].to_json
    # https://stackoverflow.com/questions/6021372/best-way-to-create-unique-token-in-rails
    # https://ruby-doc.org/stdlib-3.0.0/libdoc/securerandom/rdoc/Random/Formatter.html#method-i-urlsafe_base64
    self.secret_url_part = "#{SecureRandom.urlsafe_base64(nil, false)}#{SecureRandom.urlsafe_base64(nil, false)}"
  end
end
