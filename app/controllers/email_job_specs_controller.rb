class EmailJobSpecsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_email_job_spec, 
    only: %i[ show edit update destroy generated_emails ]

  # GET /email_job_specs or /email_job_specs.json
  def index
    #@email_job_specs = EmailJobSpec.all
    redirect_to root_path, alert: "Η πρόσβαση δεν επιτρέπεται"
    return
  end

  # GET /email_job_specs/1 or /email_job_specs/1.json
  def show
  end

  def generated_emails
    @pagynated_emails, @email_jobs = 
      pagy( EmailJob.where( email_job_spec: @email_job_spec ) )
  end

  # GET /email_job_specs/new
  def new
    @email_job_spec = EmailJobSpec.new
    @print_job_spec = nil
  end

  # GET /email_job_specs/1/edit
  def edit
  end

  def resend_failed
    @email_job_spec = EmailJobSpec.find( params[:email_job_spec_id] )
    failed_emails = @email_job_spec.email_jobs.failed

    p @email_job_spec

    failed_emails.each do |email|
      Rails.logger.info email
      EmailJobsController::create_email_job_generic @email_job_spec.id, email.id, session[ :smtp_password_pin ]
    end

    redirect_back_or_to root_path, 
      notice: "#{failed_emails.count} emails scheduled for retrasmition"
  end

  # POST /email_job_specs or /email_job_specs.json
  def create
    @email_job_spec = EmailJobSpec.new(email_job_spec_params)

    respond_to do |format|
      if @email_job_spec.save
        format.html { redirect_to email_job_spec_url(@email_job_spec), notice: "Email job spec was successfully created." }
        format.json { render :show, status: :created, location: @email_job_spec }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @email_job_spec.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /email_job_specs/1 or /email_job_specs/1.json
  def update
    respond_to do |format|
      if @email_job_spec.update(email_job_spec_params)
        format.html { redirect_to email_job_spec_url(@email_job_spec), notice: "Email job spec was successfully updated." }
        format.json { render :show, status: :ok, location: @email_job_spec }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @email_job_spec.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_job_specs/1 or /email_job_specs/1.json
  def destroy
    EmailJob.where( email_job_spec: @email_job_spec ).each do |ejob|
      ejob.destroy
    end

    @email_job_spec.destroy

    respond_to do |format|
      #format.html { redirect_to email_job_specs_url, notice: "Email job spec was successfully destroyed." }
      format.html { redirect_to root_path, notice: "Email job spec was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email_job_spec
      begin
        @email_job_spec = EmailJobSpec.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end

      if @email_job_spec.user != current_user and !current_user.is_admin?
        redirect_to root_path, alert: "Η συγκεκριμένη εργασία ανήκει σε άλλον χρήστη."
        return
      end
    end

    # Only allow a list of trusted parameters through.
    def email_job_spec_params
      params.require(:email_job_spec).permit(:print_job_spec_id, 
                                             :csv_entries, 
                                             :attachment_pattern,
                                             :subject,
                                             :body,
                                             :bcc,
                                             :cc,
                                             :smtp_account_id,
                                             :email_filename,
                                             :fixed_attachment_id,

                                            )
    end
end
