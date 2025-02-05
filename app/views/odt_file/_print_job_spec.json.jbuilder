json.extract! print_job_spec, :id, :user_id, :odt_file_id, :csv_file_id, :status, :messages, :comment, :created_at, :updated_at
json.url print_job_spec_url(print_job_spec, format: :json)
