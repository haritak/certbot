class PrintExecutionJob  < ActiveJob::Base

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

    jobSpec.update!( status: PrintJobSpec::STATUS[ :generating_odts ] )

    produced_odts = nil
    begin
      produced_odts = mco.generate_all_odts
    rescue => e
      new_status = PrintJobSpec::STATUS[ :internal_error ] + " " + e.message[0..100] 
      jobSpec.update!( status: new_status )
      print_job.destroy
      return
    end

    if !produced_odts or !produced_odts[ :filenames ] or produced_odts[ :filenames ].length == 0
      #throw Exception.new( "No ODT file was generated" ) 
      jobSpec.update!( status: PrintJobSpec::STATUS[ :internal_error ] + " No ODT file generated." )
      print_job.destroy
      return
    end

    produced_odts[ :filenames ].each do |filename|
      file_path = "#{work_dir}/#{filename}"
      if !GeneratedFile.find_by( path: file_path )
        gf = GeneratedFile.new
        gf.print_job_spec = jobSpec
        gf.path = "#{work_dir}/#{filename}"
        gf.save!
      end
    end

    jobSpec.update!( status: PrintJobSpec::STATUS[ :generating_odts_completed ] )
    jobSpec.save!
    print_job.destroy

    #
    # Create new Job for conversion to PDF
    #

    new_print_job = PrintJob.new
    new_print_job.print_job_spec = jobSpec
    new_print_job.save!

    new_execution_job = PdfCreationJob.perform_later(
        work_dir: work_dir,
        job_id: new_print_job.id
      )
    new_print_job.update( execution_job_id: new_execution_job.job_id ) # execution_job.provider_job_id
    jobSpec.update!( status: PrintJobSpec::STATUS[ :waiting_pdfs ] )
  end
end
