class SelfServiceGeneratedFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_self_service_generated_file, 
    only: %i[ show edit update destroy download regenerate ]

  # GET /self_service_generated_files or /self_service_generated_files.json
  def index
    # WARNING 
    #
    # id corresponds to SelfServicePrintJobSpec
    #
    @self_service_print_job_spec = SelfServicePrintJobSpec.find( params[ :id ] )
    @pagynated_files, @self_service_generated_files = 
      pagy( @self_service_print_job_spec.self_service_generated_files )
    @failed_generated_files = @self_service_generated_files.failed

    # Keep for future reference:
    # SelfServiceGeneratedFile.
    # joins( self_service_print_job: [self_service_print_job_spec: :print_job_spec] ).
    # where( print_job_specs: { user: current_user } )
  end

  def remove_all_odts
    # WARNING 
    #
    # params[ id ] corresponds to SelfServicePrintJobSpec
    #
    remove_all_files_of_type( :odt )
  end

  def remove_all_pdfs
    # WARNING 
    #
    # params[ id ] corresponds to SelfServicePrintJobSpec
    #
    remove_all_files_of_type( :pdf )
  end

  def regenerate
    
    # TODO : code doublication with self_service_perform
    self_service_print_job = @self_service_generated_file.self_service_print_job
    ExecuteSelfServicePrintJob.
      perform_later( rails_root: "#{Rails.root}", 
                    job_id: self_service_print_job.id,
                    regenerate_only: true
                   )

    redirect_back_or_to root_path, notice: "Job to regenerate issued"
  end


  # GET /self_service_generated_files/1 or /self_service_generated_files/1.json
  def show
  end

  # GET /self_service_generated_files/new
  def new
    @self_service_generated_file = SelfServiceGeneratedFile.new
  end

  # GET /self_service_generated_files/1/edit
  def edit
  end

  def download
    send_file @self_service_generated_file.path
  end

  # POST /self_service_generated_files or /self_service_generated_files.json
  def create
    @self_service_generated_file = SelfServiceGeneratedFile.new(self_service_generated_file_params)

    respond_to do |format|
      if @self_service_generated_file.save
        format.html { redirect_to self_service_generated_file_url(@self_service_generated_file), notice: "Self service generated file was successfully created." }
        format.json { render :show, status: :created, location: @self_service_generated_file }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @self_service_generated_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /self_service_generated_files/1 or /self_service_generated_files/1.json
  def update
    respond_to do |format|
      if @self_service_generated_file.update(self_service_generated_file_params)
        format.html { redirect_to self_service_generated_file_url(@self_service_generated_file), notice: "Self service generated file was successfully updated." }
        format.json { render :show, status: :ok, location: @self_service_generated_file }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @self_service_generated_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /self_service_generated_files/1 or /self_service_generated_files/1.json
  def destroy
    @self_service_generated_file.destroy

    respond_to do |format|
      format.html { redirect_to self_service_generated_files_url, notice: "Self service generated file was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_self_service_generated_file
      begin
        @self_service_generated_file = SelfServiceGeneratedFile.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end

      if @self_service_generated_file.user != current_user and !current_user.is_admin?
        redirect_to root_path, alert: "Το συγκεκριμένο αρχείο ανήκει σε άλλον χρήστη."
        return
      end
    end

    # Only allow a list of trusted parameters through.
    def self_service_generated_file_params
      params.require(:self_service_generated_file).permit(:self_service_print_job_id, :path)
    end

    def remove_all_files_of_type( type )
      # WARNING 
      #
      # params[ id ] corresponds to SelfServicePrintJobSpec
      #
      @self_service_print_job_spec = SelfServicePrintJobSpec.find( params[ :id ] )
      if not current_user.is_admin?
        if @self_service_print_job_spec.print_job_spec.user != current_user
          redirect_to root_path, alert: "Το συγκεκριμένο αρχείο ανήκει σε άλλον χρήστη."
        end
      end

      @self_service_generated_files = case type
                                      when :odt
                                        @self_service_print_job_spec.
                                          self_service_generated_files.odts
                                      when :pdf
                                        @self_service_print_job_spec.
                                          self_service_generated_files.pdfs
                                      end

      @self_service_generated_files.each do |file|
        file.destroy
      end
      redirect_back_or_to root_path, notice: "#{type.upcase} files removed."
    end
end
