class GeneratedFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_generated_file, 
    only: %i[show edit update destroy download send]

  # GET /generated_files or /generated_files.json
  def index
    if current_user.is_admin? 
      @generated_files = GeneratedFile.all
      @print_job_specs = nil
    else
      uid = current_user.id
      @generated_files = []
      @print_job_specs = PrintJobSpec.where( user_id: uid )
      if @print_job_specs.count > 0
        @generated_files = 
          GeneratedFile.where( 'print_job_spec_id in (?)', @print_job_specs.map {|pjs| pjs.id } )
      end
    end
  end

  # GET /generated_files/1 or /generated_files/1.json
  def show
  end

  # GET /generated_files/new
  def new
    @generated_file = GeneratedFile.new
  end

  # GET /generated_files/1/edit
  def edit
  end

  def download
    send_file @generated_file.path
  end

  def send_as_email
    @user = current_user
    generated_file = GeneratedFile.find( params[ :id ] )
    if @user.custom_smtp_account? 
      password_pin = session[ :smtp_password_pin ]
      if password_pin == "" 
        redirect_to root_path,
          alert: "Το pin είναι απαραίτητο " +
          "για την αποκρυπτογράφηση username και password"
        return
      end

      # Just try to decode username.
      # Error indicates possibly wrong password_pin
      #
      begin
        raw_smtp_username = Base64.strict_decode64(@user.smtp_account.username)
        SettingsController.decrypt(raw_smtp_username, password_pin)
      rescue => e
        redirect_back_or_to root_path,
          alert: "Η αποκρυπτογράφηση των ρυθμίσεων για την αποστολή του email απέτυχε (λάθος pin;)"
        return
      end
    end

    UserMailer.with( user_id: current_user.id,
                     attachment_path: generated_file.path,
                    smtp_password_pin: password_pin).
                    send_generated_file.deliver_later
    redirect_back_or_to root_path, notice: 'Email will be sent shortly.' 
  end

  # POST /generated_files or /generated_files.json
  def create
    @generated_file = GeneratedFile.new(generated_file_params)

    respond_to do |format|
      if @generated_file.save
        format.html { redirect_to generated_file_url(@generated_file), notice: "Generated file was successfully created." }
        format.json { render :show, status: :created, location: @generated_file }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @generated_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /generated_files/1 or /generated_files/1.json
  def update
    respond_to do |format|
      if @generated_file.update(generated_file_params)
        format.html { redirect_to generated_file_url(@generated_file), notice: "Generated file was successfully updated." }
        format.json { render :show, status: :ok, location: @generated_file }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @generated_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generated_files/1 or /generated_files/1.json
  def destroy

    # TODO : 
    # Καλύτερα να μπαίνει σε κάποιο "trashbin"
    # και να γίνεται η αφαίρεσή του από τον admin
    # σε δεύτερο χρόνο 

    if File.exist? @generated_file.path and
        File.file? @generated_file.path
      FileUtils.rm_f @generated_file.path
    end

    @generated_file.destroy

    respond_to do |format|
      format.html { redirect_to generated_files_url, notice: "Generated file was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_generated_file
      begin
        @generated_file = GeneratedFile.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end


      if @generated_file.user != current_user and !current_user.is_admin?
        redirect_to root_path, alert: "Το αρχείο ανήκει σε άλλον χρήστη."
        return
      end
    end

    # Only allow a list of trusted parameters through.
    def generated_file_params
      params.require(:generated_file).permit(:print_job_spec_id, :path)
    end
end
