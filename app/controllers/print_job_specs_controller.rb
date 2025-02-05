class PrintJobSpecsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_print_job_spec, except: %i[ index new create ]


  # GET /print_job_specs or /print_job_specs.json
  def index
    if current_user.is_admin?
      @print_job_specs = PrintJobSpec.all
    else
      @print_job_specs = PrintJobSpec.where(user_id: current_user.id) 
    end
  end

  # GET /print_job_specs/1 or /print_job_specs/1.json
  def show
  end

  def generated_files
    @pagynated_gfiles, @generated_files = 
      pagy( GeneratedFile.where( print_job_spec: @print_job_spec ) )
  end

  def remove_odts
    remove_files( :odt )
  end

  def remove_pdfs
    remove_files( :pdf )
  end

  def generated_emails
    @email_job_specs = EmailJobSpec.where( print_job_spec: @print_job_spec )
    @pagynated_emails, @email_jobs = 
      pagy( EmailJob.where( 'email_job_spec_id in (?)', @email_job_specs.map {|ejs| ejs.id } ) )
  end

  def new_email_job
    @email_job_spec = EmailJobSpec.new
    @email_job_spec.print_job_spec = @print_job_spec
  end

  def new_self_service
    @self_service_print_job_spec = SelfServicePrintJobSpec.new
    @self_service_print_job_spec.initialize_with_defaults
    @self_service_print_job_spec.print_job_spec = @print_job_spec
    @csv_file = CsvFile.new
    @odt_file = OdtFile.new
  end

  def download_backup
    send_file "#{Rails.root}/printings/#{@print_job_spec.user.email}/#{@print_job_spec.id}/#{@print_job_spec.id}.tar"
  end

  def backup
    @print_job_spec.status = PrintJobSpec::STATUS[ :backup ]
    @print_job_spec.save!

    working_dir = 
      "#{Rails.root}/printings/#{@print_job_spec.user.email}/#{@print_job_spec.id}"
    FileUtils.mkdir_p( working_dir ) if not File.exist? working_dir

    @print_job_spec.csv_file.csvfile.open do |file|
      FileUtils.cp file.path, "#{working_dir}/#{@print_job_spec.id}.csv"
    end

    @print_job_spec.odt_file.odtfile.open do |file|
      FileUtils.cp file.path, "#{working_dir}/#{@print_job_spec.id}.odt"
    end

    execution_job = TarPrintJobSpec.perform_later(
        work_dir: working_dir,
        job_id: @print_job_spec.id
      )

    respond_to do |format|
      if @print_job_spec.persisted?
        #format.html { redirect_to print_job_specs_url, notice: "Print job was successfully created." }
        format.html { redirect_to root_path, 
                      notice: "η εργασία δημιουργίας backup έχει δρομολογηθεί" }
        format.json { render :show, status: :created, location: @print_job }

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @print_job.errors, status: :unprocessable_entity }
      end
    end
  end


  # GET /print_job_specs/new
  def new
    @print_job_spec = PrintJobSpec.new
    @odt_file = OdtFile.new
    @csv_file = CsvFile.new
  end

  # GET /print_job_specs/1/edit
  def edit
  end

  # POST /print_job_specs or /print_job_specs.json
  def create
    @print_job_spec = PrintJobSpec.new
    @print_job_spec.user_id = current_user.id
    @print_job_spec.comment = print_job_spec_params[ :comment ].strip

    begin
      @odt_file = OdtFile.find( print_job_spec_params[ :odt_file_id ] )
    rescue ActiveRecord::RecordNotFound => e
      @print_job_spec.errors.add :base, "Λείπει το αρχείο ODT"
      render :new, status: :unprocessable_entity
      return
    end
    @csv_file = if print_job_spec_params[ :csv_file_id ] && 
                    print_job_spec_params[ :csv_file_id ] != ""
                  CsvFile.find( print_job_spec_params[ :csv_file_id ] )
                else
                  #nil
                  # Μέχρι να υλοποιηθεί πληρως
                  # το να είναι προαιρετικό,
                  # βάλε εδώ ένα μήνυμα
                  @print_job_spec.errors.add :base, "Λείπει το αρχείο CSV"
                  render :new, status: :unprocessable_entity
                  return
                end
    @print_job_spec.odt_file = @odt_file
    @print_job_spec.csv_file = @csv_file
    @print_job_spec.status = PrintJobSpec::STATUS[ :idle ]

    respond_to do |format|
        if @print_job_spec.save
          notice = "Η εργασία δημιουργήθηκε"
          if print_job_spec_params[ :auto_start_file_generation ] and print_job_spec_params[ :auto_start_file_generation ] == "1"
            PrintJobsController.create_print_job_for( print_job_spec: @print_job_spec )
            notice += " και έγινε η εκκίνησή της."
          else
            notice += "."
          end
          format.html { redirect_to root_path, notice: notice }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
    end
  end

  # PATCH/PUT /print_job_specs/1 or /print_job_specs/1.json
  def update

    filtered = print_job_spec_params.except :auto_start_file_generation

    respond_to do |format|
      if @print_job_spec.update( filtered )
        #format.html { redirect_to print_job_spec_url(@print_job_spec), notice: "Print job spec was successfully updated." }
        format.html { redirect_to root_path }
        format.json { render :show, status: :ok, location: @print_job_spec }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @print_job_spec.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /print_job_specs/1 or /print_job_specs/1.json
  def destroy
    if EmailJobSpec.find_by( print_job_spec: @print_job_spec )
      respond_to do |format|
        format.html { redirect_to root_path,
                      alert: "Η εργασία δεν μπορεί να διαγραφεί λόγω υπάρχουσας εργασίας αποστολής email." }
        format.json { head :no_content }
      end

      return
    end
    if PrintJob.find_by( print_job_spec: @print_job_spec )
      respond_to do |format|
        format.html { 
          redirect_to root_path, 
          status: :unprocessable_entity, 
          alert: "Η εργασία δεν μπορεί να διαγραφεί λόγω υποεργασιών εκτύπωσης." 
        }
        format.json { 
          head :no_content, 
          status: :unprocessable_entity
        }
      end
      return
    end
    if SelfServicePrintJobSpec.find_by( print_job_spec: @print_job_spec )
      respond_to do |format|
        format.html { 
          redirect_to root_path, 
          status: :unprocessable_entity, 
          alert: "Η εργασία δεν μπορεί να διαγραφεί λόγω ύπαρξης φόρμας." 
        }
        format.json { 
          head :no_content, 
          status: :unprocessable_entity
        }
      end
      return
    end

    @print_job_spec.generated_files.each do |gf|
      gf.destroy
    end

    @print_job_spec.print_jobs.each do |pj|
      pj.destroy
    end

    @print_job_spec.destroy

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Επιτυχής διαγραφή της εργασίας μαζί με παρελκόμενα email και αρχεία." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_print_job_spec
      begin
        @print_job_spec = PrintJobSpec.find(params[:id])
        @odt_file = @print_job_spec.odt_file
        @csv_file = @print_job_spec.csv_file
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end

      if @print_job_spec.user != current_user and !current_user.is_admin?
        redirect_to root_path, alert: "Η συγκεκριμένη εργασία ανήκει σε άλλον χρήστη."
        return
      end
    end

    # Only allow a list of trusted parameters through.
    def print_job_spec_params
      params.require(:print_job_spec).permit( 
                                             :comment, 
                                             :odt_file_id, 
                                             :csv_file_id,
                                             :auto_start_file_generation,
                                            )
    end

    def remove_files( type )
      selected_files = case type
                       when :odt
                         @print_job_spec.generated_files.odts
                       when :pdf
                         @print_job_spec.generated_files.pdfs
                       end
      selected_files.each do |file|
        file.destroy
      end
      redirect_back_or_to root_path, notice: "#{type.upcase} files removed."
    end
end
