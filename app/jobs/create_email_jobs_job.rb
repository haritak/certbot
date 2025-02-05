class CreateEmailJobsJob  < ActiveJob::Base

  # https://github.com/rails/rails/issues/31581
  # include Rails.application.routes.url_helpers

  # Set the Queue as Default
  queue_as :default

  rescue_from ActiveJob::DeserializationError do |exception|
    # handle a deleted user record
    Rails.logger.warn "some job was deleted before its execution ..."
  end

  def perform( email_job_spec_id:, specific_email_job_id:, 
              working_dir:, password_pin:)
    return if not email_job_spec_id
    return if not working_dir
    #return if not password_pin it's ok if using system account. (TODO)

    email_job_spec = EmailJobSpec.find( email_job_spec_id ) #may throw an exception
    jobSpec = email_job_spec.print_job_spec

    if not specific_email_job_id 

      email_job_spec.get_selected_csv_entries_with_lineno.each do |csv_line_entry|
        line_no = csv_line_entry[0]
        csv_entry = csv_line_entry[1]
        next if csv_entry.empty?  #ignore empty lines
        next if csv_entry.to_h.values.join() == ""  #previous misses some.
        next if not csv_entry[0] # ignore nil lines

        csv_entry_str = "#{line_no}: #{csv_entry}"
        if EmailJob.where( email_job_spec_id: email_job_spec.id,
            csv_entry: csv_entry_str,
            status: EmailJobSpec::STATUS[ :sent ]).count > 0
          # Job has already been sent.
          # New EmailJobSpec needs to be created to resend... (TODO)
          Rails.logger.info "csv entry #{line_no} of email job spec #{email_job_spec.id} has been sent. Not resenting"
          next
        end

        @email_job = EmailJob.new
        @email_job.email_job_spec = email_job_spec
        @email_job.csv_entry = csv_entry_str
        @email_job.status = EmailJobSpec::STATUS[ :idle ]
        @email_job.retries_left = 1 #TODO should be global configuration ? Maybe set by user in settings ?
        @email_job.save!

        execution_job = SentEmailExecutionJob.perform_later(
          work_dir: working_dir,
          email_job_id: @email_job.id,
          password_pin: password_pin,
        )

        @email_job.update!( execution_job_id: execution_job.job_id )
        @email_job.update!( status: EmailJobSpec::STATUS[ :waiting ] )
      end
    else
      begin
        @email_job = EmailJob.find( specific_email_job_id )
        new_status = EmailJobSpec::STATUS[ :retrying ]
        new_status = EmailJobSpec::STATUS[ :resent ] if @email_job.status == EmailJobSpec::STATUS[ :sent ]
        @email_job.update!( status: new_status )
        execution_job = SentEmailExecutionJob.perform_later(
          work_dir: working_dir,
          email_job_id: @email_job.id,
          password_pin: password_pin,
        )
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.warn "Couldn't find print job. Job was destroyed before execution ? :" + e.message
        return
      end
    end
  end
end
