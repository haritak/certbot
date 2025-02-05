class CsvFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_csv_file, 
    only: %i[ show edit update destroy ]

  def index
    if current_user.is_admin?
      @csv_files = CsvFile.all
    else
      @csv_files = CsvFile.where(user_id: current_user.id) 
    end
  end

  def show
  end

  def new
    @csv_file = CsvFile.new
  end

  def create
    @csv_file = CsvFile.new( csv_file_params )
    @csv_file.user_id = current_user.id
    @csv_file.filename = csv_file_params[ :csvfile ]&.original_filename
    if @csv_file.save
      redirect_to csv_files_path, notice: "CSV file created."
      #redirect_to new_print_job_spec_path
    else
      render "csv_files/new", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
    if @csv_file.user != current_user and !current_user.is_admin?
      redirect_to csv_files_path, alert: "Δεν είστε ο κάτοχος του CSV αρχείου"
      return
    end
    if PrintJobSpec.where( csv_file: @csv_file ).count == 0
      @csv_file.csvfile.purge
      @csv_file.destroy
      redirect_to csv_files_path, notice: "CSV file was successfully destroyed."
    else
      redirect_to csv_files_path, alert: "CSV file is being used and cannot be deleted"
    end
  end

  def download
  end

  private

  def set_csv_file
      begin
        @csv_file = CsvFile.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end
  end

  def csv_file_params
    params.require(:csv_file).permit(:csvfile, )
  end
end
