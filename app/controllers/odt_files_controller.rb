# Using turbo here :
# Based on : https://bhserna.com/inline-crud-hotwire.html
# Full tutorial (TODO) : https://turbo.hotwired.dev/handbook/introduction

class OdtFilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_odt_file, only: %i[ show edit update destroy ]

  def index
    if current_user.is_admin?
      @OdtFiles = OdtFile.all
    else
      @OdtFiles = OdtFile.system.or(OdtFile.where(user_id: current_user.id))
    end
  end

  def show
  end

  def new
    @odt_file = OdtFile.new
  end

  def create
    @odt_file = OdtFile.new( odt_file_params )
    @odt_file.user_id = current_user.id
    @odt_file.filename = odt_file_params[ :odtfile ]&.original_filename
    if @odt_file.save
      #redirect_to new_print_job_spec_path, notice: "Odt file created."
      redirect_to odt_files_path, notice: "ODT file created."
      #redirect_to new_print_job_spec_path
    else
      render "odt_files/new", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
    if @odt_file.user != current_user and !current_user.is_admin?
      redirect_to csv_files_path, alert: "Δεν είστε ο κάτοχος του ODT αρχείου"
      return
    end
    if PrintJobSpec.where( odt_file: @odt_file ).count == 0
      @odt_file.odtfile.purge
      @odt_file.destroy
      redirect_to odt_files_path, notice: "Odt file was successfully destroyed."
    else
      redirect_to odt_files_path, alert: "Odt file is being used and cannot be deleted"
    end
  end

  def download
  end

  private

  def set_odt_file
      begin
        @odt_file = OdtFile.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end
  end

  def odt_file_params
    params.require(:odt_file).permit(:odtfile, :system, )
  end
end
