class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    if current_user.is_admin? 
      @print_job_specs = PrintJobSpec.all.order(user_id: :asc, updated_at: :desc)
      @print_jobs = PrintJob.all
      @generated_files = GeneratedFile.all
      @email_job_specs = EmailJobSpec.all
      @email_jobs = EmailJob.all
    else
      uid = current_user.id
      @print_job_specs = PrintJobSpec.where( user_id: uid ).order(updated_at: :desc)
      @print_jobs = []
      @generated_files = []
      @email_job_specs = []
      @email_jobs = []
      if @print_job_specs.count > 0
        @print_jobs = PrintJob.where( 'print_job_spec_id in (?)', @print_job_specs.map {|pjs| pjs.id } )
        @generated_files = GeneratedFile.where( 'print_job_spec_id in (?)', @print_job_specs.map {|pjs| pjs.id } )
        @email_job_specs = EmailJobSpec.where( 'print_job_spec_id in (?)', @print_job_specs.map {|pjs| pjs.id } )
        if @email_job_specs.count > 0
          @email_jobs = EmailJob.where( 'email_job_spec_id in (?)', @email_job_specs.map {|ejs| ejs.id } )
        end
      end
    end
  end
end

