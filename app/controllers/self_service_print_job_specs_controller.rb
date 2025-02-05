class SelfServicePrintJobSpecsController < ApplicationController
  before_action :authenticate_user!, 
    except: %i[ self_service_download self_service_perform prepare_self_service_page]
  before_action :set_self_service_print_job_spec, 
    only: %i[ show edit update destroy resend_emails ]

  # GET /self_service_print_job_specs or /self_service_print_job_specs.json
  def index
    @self_service_print_job_specs = SelfServicePrintJobSpec.all
  end

  # GET /self_service_print_job_specs/1 or /self_service_print_job_specs/1.json
  def show
    @self_service_generated_files = 
      @self_service_print_job_spec.self_service_generated_files.take(50)
    @self_generated_emails = 
      @self_service_print_job_spec.self_generated_emails.take(50)
  end

  def prepare_self_service_page
    secret_url_part = params[ :secret_url_part ]
    # to add low level caching here,
    # https://guides.rubyonrails.org/caching_with_rails.html#low-level-caching
    # we should include in the secret_url_part: some sort of timestamp
    # so that in case the form is updated, we don't send stale cached data.
    # The url however should remain the same (since its the same form).
    # That is the timestamp on the secret_url_part should be removed
    # before actually searching on the database,
    # but it should be included for the cached data.
    @self_service_print_job_spec = Rails.cache.fetch("#{secret_url_part}_sspjspec", expires_in: 5.minutes) do
      begin
        sspjspec = SelfServicePrintJobSpec.find_by( secret_url_part: secret_url_part )
      rescue 
        redirect_to root_path, alert: "Η διεύθυνση που ζητήσατε δεν βρέθηκε."
        return
      end
      sspjspec
    end
    @form_parts = Rails.cache.fetch("#{secret_url_part}_formparts}", expires: 5.minutes) do
      JSON.parse @self_service_print_job_spec.field_names # may throw exception!!!
    end

    render layout: "prepare_self_service_page_layout"
  end

  def self_service_perform
    @myJob = SelfServicePrintJob.new
    @myJob.self_service_print_job_spec = SelfServicePrintJobSpec.
      find( params[ :self_service_print_job_spec_id ] )
    @myJob.user_specific_page = "#{SecureRandom.urlsafe_base64(nil, false)}"

    @field_names = JSON.parse @myJob.self_service_print_job_spec.field_names
    field_values = {}
    @field_names.each do | field_name |
      param_name = field_name["odt_name"]
      param_value = params[ param_name ]
      field_values[ param_name ] = param_value
      if param_name =~ /email/i
        if param_value !~ URI::MailTo::EMAIL_REGEXP
          @self_service_print_job_spec = @myJob.self_service_print_job_spec
          @form_parts = JSON.parse @self_service_print_job_spec.field_names # may throw exception!!!
          flash.now[:alert] = "Το email δεν έχει αποδεκτή μορφή"
          render "prepare_self_service_page",
            alert: "Το email δεν έχει αποδεκτή μορφή",
            status: :unprocessable_entity
          return
        else
          @myJob.recipient = param_value
        end
      end
    end

    @myJob.field_values = field_values.to_json
    @myJob.save!

    jobSpec = @myJob.self_service_print_job_spec.print_job_spec
    user_email = jobSpec.user.email
    rails_root = Rails.root
    odt_file = "#{jobSpec.id}.odt"
    csv_file = "#{jobSpec.id}.csv"
    odt_full_path = "#{rails_root}/printings/#{user_email}/#{jobSpec.id}/#{odt_file}"
    csv_full_path = "#{rails_root}/printings/#{user_email}/#{jobSpec.id}/#{csv_file}"
    if not File.exist? odt_full_path
      working_dir = "#{rails_root}/printings/#{user_email}/#{jobSpec.id}"
      FileUtils.mkdir_p( working_dir ) if not File.exist? working_dir
      jobSpec.odt_file.odtfile.open do |file|
        FileUtils.cp file.path, "#{working_dir}/#{odt_file}"
      end
      jobSpec.csv_file.csvfile.open do |file|
        FileUtils.cp file.path, "#{working_dir}/#{csv_file}"
      end
    end

    ExecuteSelfServicePrintJob.perform_later( rails_root: "#{Rails.root}", job_id: @myJob.id )

    redirect_to self_service_download_path( user_specific_page: @myJob.user_specific_page ), 
      notice: "Αν το αρχείο σας δεν είναι έτοιμο ανανεώστε την σελίδα."
    return
  end

  def self_service_download
    @secret_url_part = params[ :secret_url_part ]
    @user_specific_page = params[ :user_specific_page ]
    @myJob = SelfServicePrintJob.find_by( user_specific_page: @user_specific_page )
    jobSpec = @myJob.self_service_print_job_spec.print_job_spec
    @work_dir = "#{Rails.root}/self_generated_files/#{jobSpec.user.email}/#{jobSpec.id}/#{@user_specific_page}"

    @field_names = JSON.parse @myJob.self_service_print_job_spec.field_names
    @field_values = JSON.parse @myJob.field_values

    render layout: "prepare_self_service_page_layout"
  end

  # GET /self_service_print_job_specs/new
  def new
    @self_service_print_job_spec = SelfServicePrintJobSpec.new
    @self_service_print_job_spec.initialize_with_defaults
  end


  # GET /self_service_print_job_specs/1/edit
  def edit
  end

  def resend_emails
    failed_emails = @self_service_print_job_spec.
      self_generated_emails.failed

    failed_emails.each do |email|
      SelfGeneratedEmailsController::resend_email email
    end

    redirect_back_or_to root_path, 
      notice: "#{failed_emails.count} emails scheduled for retrasmition"
  end

  # POST /self_service_print_job_specs or /self_service_print_job_specs.json
  def create
    @self_service_print_job_spec = SelfServicePrintJobSpec.
      new(self_service_print_job_spec_params)

    @print_job_spec = PrintJobSpec.
      find( self_service_print_job_spec_params[ :print_job_spec_id ] )

    respond_to do |format|
      if @self_service_print_job_spec.save
        format.html { redirect_to self_service_print_job_spec_url(@self_service_print_job_spec), 
                        notice: "Η δημιουργία φόρμας ολοκληρώθηκε." }
      else
        format.html {
          render "print_job_specs/new_self_service", 
          status: :unprocessable_entity
        }
      end
    end
  end

  # PATCH/PUT /self_service_print_job_specs/1 or /self_service_print_job_specs/1.json
  def update
    respond_to do |format|
      if @self_service_print_job_spec.update(self_service_print_job_spec_params)
        format.html { redirect_to self_service_print_job_spec_url(@self_service_print_job_spec), notice: "Self service print job spec was successfully updated." }
        format.json { render :show, status: :ok, location: @self_service_print_job_spec }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @self_service_print_job_spec.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /self_service_print_job_specs/1 or /self_service_print_job_specs/1.json
  def destroy
    @self_service_print_job_spec.self_generated_emails.destroy_all
    @self_service_print_job_spec.self_service_print_jobs.destroy_all
    # will be destroyed by the self_service_print_jobs 
    # @self_service_print_job_spec.self_service_generated_files.destroy_all
    @self_service_print_job_spec.destroy

    respond_to do |format|
      format.html { redirect_to root_path, 
                    notice: "Η φόρμα καταστράφηκε μαζί με όλα τα emails και αρχεία που είχε δημιουργήσει." }
    end
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

    # Only allow a list of trusted parameters through.
    def self_service_print_job_spec_params
      params.require(:self_service_print_job_spec).
        permit(
          :print_job_spec_id, 
          :secret_url_part, 
          :title, 
          :active, 
          :field_names, 
          :validate_client_email,
          :smtp_account_id,
          :send_email,
          :direct_download,

          #filenames
          :css,
          :banner,
          :gdpr
        )
    end
end
