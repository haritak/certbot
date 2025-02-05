class SentSelfGeneratedEmailJob < ApplicationJob
  queue_as :default

  rescue_from ActiveJob::DeserializationError do |exception|
    # handle a deleted user record
    Rails.logger.warn "some print job was deleted before its execution ..."
  end

  def perform( self_generated_email_id: )
    return if not self_generated_email_id

    sg_email = SelfGeneratedEmail.find( self_generated_email_id ) #throws exception if not found ...
    if not File.exist? sg_email.attachment_path
      sg_email.update!( status: "Attachment file missing" )
      return
    end

    begin
      UserMailer.with( smtp_account_id: sg_email.self_service_print_job_spec.smtp_account.id,
                       attachment_path: sg_email.attachment_path,
                       recipient: sg_email.recipient
                     ).send_self_generated_file.deliver
    rescue => e
      sg_email.update!( status: EmailJobSpec::STATUS[ :internal_error ] + " :" + e.message[0..200] + "[...]" )
      return
    end

    sg_email.update!( status: EmailJobSpec::STATUS[ :sent ] )
  end
end
