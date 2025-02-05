class UserMailer < ApplicationMailer

  def test_smtp_server_email
    @log = Rails.logger
    smtp_password_pin = params[ :smtp_password_pin ]
    smtp_account = SmtpAccount.find( params[ :smtp_account_id ] )
    user = User.find( params[ :user_id ] )

    if smtp_password_pin
      u = Base64.strict_decode64(smtp_account.username)
      p = Base64.strict_decode64(smtp_account.password)
      decoded_smtp_username = SettingsController.decrypt( u, smtp_password_pin )
      decoded_smtp_password = SettingsController.decrypt( p, smtp_password_pin )
    end
    smtp_server = smtp_account.server
    smtp_port = smtp_account.port
    smtp_from = smtp_account.from
    smtp_username = 
      smtp_password_pin ? decoded_smtp_username : smtp_account.username
    smtp_password = 
      smtp_password_pin ? decoded_smtp_password : smtp_account.password
    subject = "Δοκιμαστικό email (#{smtp_account.description})"

    @log.info "Using #{smtp_server} : #{smtp_port} to deliver email"

    delivery_options = {
      address: smtp_server,
      port: smtp_port,
      user_name: smtp_username,
      password: smtp_password,
    }

    headers[ :Certbot_Testing_Email ] = "u#{user.id}_sa#{smtp_account.id}"
    m = mail(from: smtp_from,
             to: user.email,
             subject: "#{subject} - Οι ρυθμίσεις φαίνονται ΟΚ",
             delivery_method_options: delivery_options)
  end

  def send_generated_file
    @log = Rails.logger
    smtp_password_pin = params[ :smtp_password_pin ]
    user = User.find( params[ :user_id ] )
    email_job = EmailJob.find( params[ :email_job_id ] )
    smtp_account = email_job.email_job_spec.smtp_account
    attachment_path = params[ :attachment_path ]

    trgFileExtension = File.extname attachment_path #May throw FileNotFoundException
    trgEmail = File.basename attachment_path, trgFileExtension
    trgEmail = trgEmail[ (trgEmail.index("_")+1)..] # Reminder: filename is INDEX_email."

    if smtp_account.custom_smtp_account?
      if user.id != smtp_account.user_id
        @log.error "Missmatch on ownership of outgoing smtp_account. (#{user.id}!=#{smtp_account.user_id})"
        throw Exception.new "Missmatch on ownership of outgoing smtp_account."
      end
      u = Base64.strict_decode64(smtp_account.username)
      p = Base64.strict_decode64(smtp_account.password)
      decoded_smtp_username = SettingsController.decrypt( u, smtp_password_pin )
      decoded_smtp_password = SettingsController.decrypt( p, smtp_password_pin )
    end
    smtp_server = smtp_account.server
    smtp_port = smtp_account.port
    smtp_from = smtp_account.from
    smtp_username = 
      smtp_password_pin ? decoded_smtp_username : smtp_account.username
    smtp_password = 
      smtp_password_pin ? decoded_smtp_password : smtp_account.password

    @log.info "Using #{smtp_server} : #{smtp_port} to deliver email to #{trgEmail}"

    delivery_options = {
      address: smtp_server,
      port: smtp_port,
      user_name: smtp_username,
      password: smtp_password,
    }


    atFn = "Certificate#{trgFileExtension}" 
    attachments[ atFn ] = File.read( attachment_path )
    if email_job.email_job_spec.fixed_attachment
      fa = email_job.email_job_spec.fixed_attachment
      if fa.fixed and fa.fixed.attached?
        fa.fixed.open do |file|
          attachments[ fa.email_filename ] = File.read( file.path )
        end
      end
    end
    headers[ :Certbot_Send_Email ] =
      "u#{user.id}_sa#{smtp_account.id}_ap#{attachment_path.split("/")[-2..].join(".")}"
    @email_subject = email_job.email_job_spec.subject
    @email_body = email_job.email_job_spec.body
    @bcc = email_job.email_job_spec.bcc
    @cc = email_job.email_job_spec.cc
    m = mail(from: smtp_from,
             to: trgEmail,
             bcc: @bcc,
             cc: @cc,
             subject: @email_subject,
             delivery_method_options: delivery_options)
    @log.info "Email from #{smtp_account.from} to #{trgEmail} with attachment #{atFn} delivered to SMTP server."
  end

  def send_self_generated_file
    smtp_account_id = params[ :smtp_account_id ]
    attachment_path = params[ :attachment_path ]
    recipient = params[ :recipient ]

    @log = Rails.logger
    smtp = SmtpAccount.find( smtp_account_id )

    delivery_options = {
      address: smtp.server,
      port: smtp.port,
      user_name: smtp.username,
      password: smtp.password,
    }

    trgFileExtension = File.extname attachment_path #May throw FileNotFoundException
    atFn = "Certificate#{trgFileExtension}" 
    attachments[ atFn ] = File.read( attachment_path )
    headers[ :Certbot_SelfGenerated_Email ] =
      "sa#{smtp.id}_ap#{attachment_path.split("/")[-3..].join(".")}"
    m = mail(from: smtp.from,
             to: recipient,
             subject: "Βεβαίωση", #TODO το θέμα του email.
             delivery_method_options: delivery_options)
    @log.info "Email from #{smtp.from} to #{recipient} with attachment #{attachment_path} delivered to SMTP server."
  end

  
end
