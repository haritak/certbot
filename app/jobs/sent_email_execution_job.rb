class SentEmailExecutionJob  < ActiveJob::Base

  # https://github.com/rails/rails/issues/31581
  # include Rails.application.routes.url_helpers

  # Set the Queue as Default
  queue_as :default

  rescue_from ActiveJob::DeserializationError do |exception|
    # handle a deleted user record
    Rails.logger.warn "some print job was deleted before its execution ..."
  end

  def perform( work_dir:, email_job_id:, password_pin: )
    return if not email_job_id
    return if not work_dir

    email_job = EmailJob.find( email_job_id ) #throws exception if not found
    emailJobSpec = email_job.email_job_spec #will throw exception if not found
    printJobSpec = emailJobSpec.print_job_spec #will throw exception if something is missing

    csv_file = "#{work_dir}/#{printJobSpec.id}.csv"
    [work_dir, csv_file].each do | target |
      puts "Missing #{target}." if not File.exist? target
      if not File.exist? target
        email_job.update!( status: EmailJobSpec::STATUS[ :internal_error ] + " missing required file. Try recreating the print job" )
        return 
      end
    end

    if not emailJobSpec.smtp_account
        status_msg = EmailJobSpec::STATUS[ :internal_error ] + 
          " Δεν έχει επιλεχθεί λογαριασμός για την αποστολή των email."
        email_job.update!( status: status_msg )
        return 
    end

    if emailJobSpec.smtp_account.custom_smtp_account?
      if emailJobSpec.smtp_account.user_id != printJobSpec.user_id
        status_msg = EmailJobSpec::STATUS[ :internal_error ] + 
          " Missmatch on user. Account is not owned by user submitting the job."
        email_job.update!( status: status_msg )
        return
      end
      # Just try to decode username.
      # Error indicates possibly wrong password_pin
      #
      smtp_username = emailJobSpec.smtp_account.username
      begin
        raw_smtp_username = Base64.strict_decode64(smtp_username)
        SettingsController.decrypt(raw_smtp_username, password_pin)
      rescue => e
        status_msg = EmailJobSpec::STATUS[ :internal_error ] + 
          " Η αποκρυπτογράφηση των ρυθμίσεων για την αποστολή του email απέτυχε (λάθος pin;)"
        email_job.update!( status: status_msg )
        return 
      end
    end

    begin
      csv_entry = email_job.csv_entry

      trg_email = csv_entry.split(",")[ -1 ].strip 
      csv_line  = csv_entry.split(":")[  0 ].strip

      extension = "pdf"
      extension = "odt" if email_job.email_job_spec.attachment_pattern =~ /odt/i

      attachment_path = "#{work_dir}/#{csv_line}_#{trg_email}.#{extension}"
      if not File.exist? attachment_path
        throw Exception.new( "File not found : #{attachment_path}" )
      end

      UserMailer.with(user_id: printJobSpec.user.id,
                      email_job_id: email_job.id,
                      attachment_path: attachment_path,
                      smtp_password_pin: password_pin).
                      send_generated_file.deliver
    rescue => e
      error_message = EmailJobSpec::STATUS[ :internal_error ] +
                        " Error while sending email:" + e.message
      email_job.update!( status: error_message[..200] + "..." )
      Rails.logger.error error_message
      return 
    end

    Rails.logger.info "Email job #{email_job.id} (#{attachment_path}) was sent."
    email_job.update!( status: EmailJobSpec::STATUS[ :sent ] )
  end
end
