class FixedAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fixed_attachment, 
    only: %i[ show edit update destroy ]

  def index
    if current_user.is_admin?
      @fixed_attachments = FixedAttachment.all
    else
      @fixed_attachments = FixedAttachment.where(user_id: current_user.id) 
    end
  end

  def show
  end

  def new
    @fixed_attachment = FixedAttachment.new
  end

  def create
    @fixed_attachment = FixedAttachment.new( fixed_attachment_params )
    @fixed_attachment.user_id = current_user.id
    if @fixed_attachment.email_filename == nil or @fixed_attachment.email_filename.strip == ""
      @fixed_attachment.email_filename = @fixed_attachment.fixed.filename
    end
    if @fixed_attachment.save
      redirect_to fixed_attachments_path, notice: "Fixed attachment file created."
      #redirect_to new_print_job_spec_path
    else
      render "fixed_attachments/new", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
    if @fixed_attachment.user != current_user and !current_user.is_admin?
      redirect_to fixed_attachments_path, alert: "Δεν είστε ο κάτοχος του Fixed attachment αρχείου"
      return
    end
    if EmailJobSpec.where( fixed_attachment: @fixed_attachment ).count == 0
      @fixed_attachment.fixed.purge
      @fixed_attachment.destroy
      redirect_to fixed_attachments_path, notice: "Fixed attachment file was successfully destroyed."
    else
      redirect_to fixed_attachments_path, alert: "Fixed attachment file is being used and cannot be deleted"
    end
  end

  def download
  end

  private

  def set_fixed_attachment
      begin
        @fixed_attachment = FixedAttachment.find( params[:id] )
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end
  end

  def fixed_attachment_params
    params.require(:fixed_attachment).permit(:fixed, :email_filename,)
  end
end
