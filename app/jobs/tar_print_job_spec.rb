class TarPrintJobSpec  < ActiveJob::Base

  # https://github.com/rails/rails/issues/31581
  # include Rails.application.routes.url_helpers

  # Set the Queue as Default
  queue_as :default

  rescue_from ActiveJob::DeserializationError do |exception|
    # handle a deleted user record
    Rails.logger.warn "some job was deleted before its execution ..."
  end

  def perform( work_dir:, job_id: )
    if !work_dir or !job_id
      Rails.logger.warn "Either work_dir or job_id is empty."
      return
    end

    jobSpec = nil
    begin
      jobSpec = PrintJobSpec.find( job_id )
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.warn "Couldn't find print job spec. Job spec was destroyed before execution ? :" + e.message
      return
    end

    csv_file = "#{work_dir}/#{jobSpec.id}.csv"
    odt_file = "#{work_dir}/#{jobSpec.id}.odt"
    [work_dir, csv_file, odt_file].each do | target |
      puts "Missing #{target}." if not File.exist? target
      if not File.exist? target
        Rails.logger.warn "Missing file #{target}. Aborting job."
        return
      end
    end

    begin
      FileUtils.rm_f "#{work_dir}/#{jobSpec.id}.tar"
    rescue => e
      Rails.logger.warn "Ignoring error while removing previous backup."
    end

    begin
      tmpFile = Tempfile.new "#{jobSpec.id}"
      tmpFile.close

      `tar cf #{tmpFile.path} #{work_dir}/`
      if not $?.success?
        throw Exception.new "Failed to create tar file #{tmpFile.path} for #{work_dir}"
      end

      FileUtils.cp tmpFile.path, "#{work_dir}/#{jobSpec.id}.tar"
    rescue => e
      new_status = PrintJobSpec::STATUS[ :internal_error ] + " " + e.message[0..100] 
      jobSpec.update!( status: new_status )
      return
    end

    begin
      tmpFile.unlink
    rescue => e
      Rails.logger.warn "Ignoring unlinking of temporary file."
    end

    jobSpec.update!( status: PrintJobSpec::STATUS[ :finished ] )
  end
end
