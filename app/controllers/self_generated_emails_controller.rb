class SelfGeneratedEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_self_service_print_job_spec, except: %i[ resend ]
  def index
    @pagynated_emails, @self_generated_emails = 
      pagy( @self_service_print_job_spec.self_generated_emails )
    @failed_self_generated_emails = @self_generated_emails.failed
  end

  def SelfGeneratedEmailsController.resend_email( email )
    SentSelfGeneratedEmailJob.
      perform_later( self_generated_email_id: email.id )
  end

  def resend
    # TODO code doublication with  ExecuteSelfServicePrintJob::perform

    #
    # WARNING: (ugly) (TODO)
    #
    #  id param
    #
    #  is the if of the self_generated_email for this call.
    #
    # (and not of self_service_print_job_spec)
    #
    sg_email = SelfGeneratedEmail.find( params[:id] )
    sg_email.update!( status: "RESENDING" )

    SelfGeneratedEmailsController::resend_email( sg_email )

    redirect_back_or_to root_path, notice: "Email scheduled to be resend"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_self_service_print_job_spec
      begin
        @self_service_print_job_spec = SelfServicePrintJobSpec.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end

      if @self_service_print_job_spec.user != current_user and !current_user.is_admin?
        redirect_to root_path, alert: "Η συγκεκριμένη εργασία ανήκει σε άλλον χρήστη."
        return
      end
    end
end
