class EmailJobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_email_job, 
  except: %i[ index new create ]

  # GET /email_jobs or /email_jobs.json
  def index
    if current_user.is_admin? 
      @email_jobs = EmailJob.all
    else
      uid = current_user.id
      @email_jobs = []
      @print_job_specs = PrintJobSpec.where( user_id: uid )
      if @print_job_specs.count > 0
        @email_job_specs = EmailJobSpec.where( 'print_job_spec_id in (?)', @print_job_specs.map {|pjs| pjs.id } )
        if @email_job_specs.count > 0
          @email_jobs = EmailJob.where( 'email_job_spec_id in (?)', @email_job_specs.map {|ejs| ejs.id } )
        end
      end
    end
  end

  # GET /email_jobs/1 or /email_jobs/1.json
  def show
  end


  # GET /email_jobs/new
  def new
    @email_job = EmailJob.new
  end

  # GET /email_jobs/1/edit
  def edit
  end

  # POST /email_jobs or /email_jobs.json
  def create
    if create_the_email_job( email_job_params[ :id ] )
      respond_to do |format|
        #format.html { redirect_to email_job_url(@email_job), notice: "Email job was successfully created." }
        format.html { redirect_to root_path, notice: "Η αποστολή των email έχει δρομολογηθεί." }
        format.json { render :show, status: :created, location: @email_job }
      end
    else
      respond_to do |format|
        #format.html { redirect_to email_job_url(@email_job), notice: "Email job was successfully created." }
        format.html { redirect_to root_path, 
                      status: :unprocessable_entity,
                      alert: "Cannot start without a password pin." }
      end
    end
  end

  def resend
    if create_the_email_job( @email_job.email_job_spec.id, @email_job.id )
      respond_to do |format|
        #format.html { redirect_to email_job_url(@email_job), notice: "Email job was successfully created." }
        format.html { 
          redirect_back_or_to root_path, notice: "To email θα αποσταλεί σύντομα." 
        }
        format.json { render :show, status: :created, location: @email_job }
      end
    else
      respond_to do |format|
        #format.html { redirect_to email_job_url(@email_job), notice: "Email job was successfully created." }
        format.html { redirect_to root_path, 
                      status: :unprocessable_entity,
                      alert: "Cannot start without a password pin." }
      end
    end
  end

  # PATCH/PUT /email_jobs/1 or /email_jobs/1.json
  def update
    respond_to do |format|
      if @email_job.update(email_job_params)
        format.html { redirect_to email_job_url(@email_job), notice: "Email job was successfully updated." }
        format.json { render :show, status: :ok, location: @email_job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @email_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_jobs/1 or /email_jobs/1.json
  def destroy
    @email_job.destroy

    respond_to do |format|
      #format.html { redirect_to email_jobs_url, notice: "Email job was successfully destroyed." }
      format.html { redirect_back_or_to root_path, notice: "Έγινε η διαγραφή της εργασίας αποστολής email." }
      format.json { head :no_content }
    end
  end

  def create_the_email_job( email_job_spec_id, specific_email_job_id = nil )
    email_job_spec = EmailJobSpec.find( email_job_spec_id )
    if email_job_spec.smtp_account.custom_smtp_account?
      return false if not session[ :smtp_password_pin ]
    end

    EmailJobsController::create_email_job_generic(email_job_spec_id, 
                                                  specific_email_job_id,
                                                  session[ :smtp_password_pin ],
                                                 )
  end

  def self.create_email_job_generic( email_job_spec_id, specific_email_job_id, passpin)
    email_job_spec = EmailJobSpec.find( email_job_spec_id )
    jobSpec = email_job_spec.print_job_spec
    working_dir = 
      "#{Rails.root}/printings/#{jobSpec.user.email}/#{jobSpec.id}"

    CreateEmailJobsJob.perform_later(
      email_job_spec_id: email_job_spec_id,
      specific_email_job_id: specific_email_job_id,
      working_dir: working_dir,
      password_pin: passpin,
    )

    return true
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_email_job
    begin
      @email_job = EmailJob.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      redirect_to root_path, alert: "Δεν βρέθηκε"
      return
    end
    if @email_job.user != current_user and !current_user.is_admin?
      redirect_to root_path, alert: "Η συγκεκριμένη εργασία ανήκει σε άλλον χρήστη."
      return
    end
  end

  # Only allow a list of trusted parameters through.
  def email_job_params
    #params.require(:email_job).permit(:email_job_spec_id, :execution_job_id, :csv_entry, :status, :retries_left)
    params.require(:email_job_spec).permit( :id )
  end
end
