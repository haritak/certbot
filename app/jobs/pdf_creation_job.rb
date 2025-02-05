class PdfCreationJob  < ActiveJob::Base

  # https://github.com/rails/rails/issues/31581
  # include Rails.application.routes.url_helpers

  # Currently this queue should serve one job
  # at a time so that there is no problem with the
  # conversion of odt to pdf from libreoffice
  queue_as :odt2pdf

  rescue_from ActiveJob::DeserializationError do |exception|
    # handle a deleted user record
    Rails.logger.warn "some job was deleted before its execution ..."
  end

  def perform( work_dir:, job_id: )
    if !work_dir or !job_id
      return
    end

    print_job = nil
    begin
      print_job = PrintJob.find( job_id )
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.warn "Couldn't find print job. Job was destroyed before execution ? :" + e.message
      return
    end
    jobSpec = print_job.print_job_spec

    csv_file = "#{work_dir}/#{jobSpec.id}.csv"
    odt_file = "#{work_dir}/#{jobSpec.id}.odt"
    [work_dir, csv_file, odt_file].each do | target |
      puts "Missing #{target}." if not File.exist? target
      if not File.exist? target
        Rails.logger.warn "Missing file #{target}. Aborting job."
        print_job.destroy
        return
      end
    end

    mco = MergeConvertOdt.new(work_dir: work_dir, odt_file: odt_file, csv_file: csv_file)

    jobSpec.status = PrintJobSpec::STATUS[ :generating_pdfs ]
    jobSpec.save!

    produced_pdfs = nil
    begin
      produced_pdfs = mco.generate_missing_pdfs
    rescue => e
      new_status = PrintJobSpec::STATUS[ :internal_error ] + " " + e.message[0..100] 
      jobSpec.update!( status: new_status )
      print_job.destroy
      return
    end

    produced_pdfs.each do |filename|
      file_path = "#{work_dir}/#{filename}"
      if !GeneratedFile.find_by( path: file_path )
        gf = GeneratedFile.new
        gf.print_job_spec = jobSpec
        gf.path = "#{work_dir}/#{filename}"
        gf.save!
      end
    end

    jobSpec.status = PrintJobSpec::STATUS[ :finished ]
    jobSpec.save!

    print_job.destroy
  end
end
