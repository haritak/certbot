class AddIndexesToVariousTables < ActiveRecord::Migration[7.0]
  def change
    add_index :print_job_specs, :user_id, if_not_exists: true

    add_index :print_jobs, :print_job_spec_id, if_not_exists: true

    add_index :email_job_specs, :print_job_spec_id, if_not_exists: true


    add_index :self_service_print_job_specs, :print_job_spec_id, if_not_exists: true
    add_index :self_service_print_job_specs, :secret_url_part, if_not_exists: true

    add_index :email_jobs, :email_job_spec_id, if_not_exists: true
    
    add_index :generated_files, :print_job_spec_id, if_not_exists: true
    add_index :generated_files, :path, if_not_exists: true

    add_index :self_generated_emails, :self_service_print_job_spec_id, if_not_exists: true
    add_index :self_generated_emails, :status, if_not_exists: true

    add_index :self_service_generated_files, :self_service_print_job_id, if_not_exists: true
    add_index :self_service_generated_files, :path, if_not_exists: true
    add_index :self_service_generated_files, :status, if_not_exists: true

    add_index :self_service_print_jobs, :self_service_print_job_spec_id, if_not_exists: true
    add_index :self_service_print_jobs, :user_specific_page, if_not_exists: true
  end
end
