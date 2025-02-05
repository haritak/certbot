json.extract! email_job, :id, :email_job_spec_id, :execution_job_id, :csv_entry, :status, :retries_left, :created_at, :updated_at
json.url email_job_url(email_job, format: :json)
