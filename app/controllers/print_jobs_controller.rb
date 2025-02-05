class PrintJobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_print_job, 
    only: %i[ show edit update destroy ]

  # GET /print_jobs or /print_jobs.json
  def index
    if current_user.is_admin?
      @print_jobs = PrintJob.all
    else
      @print_jobs = PrintJob.user( current_user )
    end
  end

  # GET /print_jobs/1 or /print_jobs/1.json
  def show
  end

  # GET /print_jobs/new
  def new
    @print_job = PrintJob.new
  end

  # GET /print_jobs/1/edit
  def edit
  end

  # POST /print_jobs or /print_jobs.json
  def create
    print_job_spec = PrintJobSpec.find( print_job_params[ :id ] )
    if not print_job_spec
      throw Exception.new( "Λείπουν οι προδιαγραφές τις εργασίας δημιουργίας αρχείων" )
    end

    @print_job = self.class.create_print_job_for( print_job_spec: print_job_spec )

    respond_to do |format|
      if @print_job.persisted?
        #format.html { redirect_to print_job_specs_url, notice: "Print job was successfully created." }
        format.html { redirect_to root_path, 
                      notice: "η εργασία δημιουργίας αρχείων έχει δρομολογηθεί" }
        format.json { render :show, status: :created, location: @print_job }

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @print_job.errors, status: :unprocessable_entity }
      end
    end
  end

  def self.create_print_job_for( print_job_spec: )
    @print_job = PrintJob.new
    @print_job.print_job_spec = print_job_spec

    print_job_spec.status = PrintJobSpec::STATUS[ :preparing ]
    print_job_spec.save!

    if @print_job.save
      jobSpec = @print_job.print_job_spec
      working_dir = 
        "#{Rails.root}/printings/#{jobSpec.user.email}/#{jobSpec.id}"
      FileUtils.mkdir_p( working_dir ) if not File.exist? working_dir

      jobSpec.csv_file.csvfile.open do |file|
        FileUtils.cp file.path, "#{working_dir}/#{jobSpec.id}.csv"
      end

      jobSpec.odt_file.odtfile.open do |file|
        FileUtils.cp file.path, "#{working_dir}/#{jobSpec.id}.odt"
      end

      execution_job = 
        PrintExecutionJob.perform_later(
          work_dir: working_dir,
          job_id: @print_job.id
        )
      @print_job.update( execution_job_id: execution_job.job_id ) # execution_job.provider_job_id
      print_job_spec.update( status: PrintJobSpec::STATUS[ :waiting ] )
    end

    @print_job
  end

  # PATCH/PUT /print_jobs/1 or /print_jobs/1.json
  def update
    respond_to do |format|
      if @print_job.update(print_job_params)
        #format.html { redirect_to print_job_url(@print_job), notice: "Print job was successfully updated." }
        format.html { redirect_to root_path, 
                      notice: "Print job was successfully updated." }
        format.json { render :show, status: :ok, location: @print_job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @print_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /print_jobs/1 or /print_jobs/1.json
  def destroy
    @print_job.print_job_spec.status = "IDLE" # ??? TODO...
    @print_job.destroy

    respond_to do |format|
      format.html { redirect_to root_path, 
                    notice: "Print job was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_print_job
      begin
        @print_job = PrintJob.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end

      if @print_job.print_job_spec.user != current_user and !current_user.is_admin?
        redirect_to root_path, alert: "Η συγκεκριμένη εργασία ανήκει σε άλλον χρήστη."
        return
      end
    end

    # Only allow a list of trusted parameters through.
    def print_job_params
      params.require(:print_job_spec).permit( :id )
    end
end
