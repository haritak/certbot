class ExecuteSelfServicePrintJob < ApplicationJob

  # since this job will perform both
  # odt generation and pdf creation
  # place it in a queue which executes only one
  # job (1 processor)
  queue_as :odt2pdf

  rescue_from ActiveJob::DeserializationError do |exception|
    # handle a deleted user record
    Rails.logger.warn "some job was deleted before its execution ..."
  end

  def perform( rails_root:, job_id:, regenerate_only: false)
    return if !job_id
    return if !rails_root

    myJob = nil
    begin
      myJob = SelfServicePrintJob.find job_id
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.warn "Couldn't find self service job. Job was destroyed before execution ? :" + e.message
      return
    end
    jobSpec = myJob.self_service_print_job_spec.print_job_spec
    user_email = jobSpec.user.email
    odt_file = "#{jobSpec.id}.odt"
    csv_file = "#{jobSpec.id}.csv"
    odt_full_path = "#{rails_root}/printings/#{user_email}/#{jobSpec.id}/#{odt_file}"
    csv_full_path = "#{rails_root}/printings/#{user_email}/#{jobSpec.id}/#{csv_file}"

    work_dir = "#{rails_root}/self_generated_files/#{user_email}/#{jobSpec.id}" 
    work_dir = "#{work_dir}/#{myJob.user_specific_page}"
    FileUtils.mkdir_p( work_dir ) if not File.exist? work_dir
    #
    # Η ιδέα εδώ είναι να γλυτώσουμε χώρο στον δίσκο
    # αλλά θα πρέπει να υποστηρίζει το σύστημα αρχείων 
    # hard links
    #
    # FileUtils.cp( odt_full_path, work_dir )
    #
    FileUtils.ln( odt_full_path, work_dir, force: true )


    Dir.chdir( work_dir )


    #
    # Δημιουργία ODT
    #
    trgFilename = "certificate.odt" 
    trgPath = "#{work_dir}/#{trgFilename}"
    ssgf = SelfServiceGeneratedFile.
      where( self_service_print_job: myJob, path: "#{work_dir}/#{trgFilename}" ).first
    if not ssgf
      ssgf = SelfServiceGeneratedFile.new
      ssgf.self_service_print_job = myJob
      ssgf.path = trgPath
      ssgf.status = SelfServiceGeneratedFile::STATUS[:idle]
      ssgf.save!
    end

    if File.exist? trgFilename
      Rails.logger.info "Reusing old file #{trgFilename} for self service job #{myJob.id}"
      # ssgf.update!( status: SelfServiceGeneratedFile::STATUS[:created] )
    else
      ssgf.update!( status: SelfServiceGeneratedFile::STATUS[:preparing_1] )
      field_names = JSON.parse myJob.self_service_print_job_spec.field_names
      field_values = JSON.parse myJob.field_values
      generatedOdt = ODFReport::Report.new( odt_file ) do |r|
        gender = "unknown"
        field_names.each do |header|
          header_symbol = header["odt_name"]&.strip.downcase.to_sym
          value = field_values[ header["odt_name"] ]&.strip
          r.add_field header_symbol, value

          if header["odt_name"] =~ /GENDER/i
            case value
            when 'ο' then gender = "male"
            when 'η' then gender = "female"
            else gender = "unknown"
            end
          end
        end
        if gender != "unknown"
          # εδώ χρειάζεται:
          # * ευρύτερη υλοποίηση (με κλίση ονομάτων)
          # * καλύτερο documentation για τον end user (TODO)
          if gender == "female"
            r.add_field :o, "η"
            r.add_field :ton, "την"
            r.add_field :ston, "στην"
            r.add_field :toy, "της"
            r.add_field :student, "μαθήτρια"
            r.add_field :student_gen, "μαθήτριας"
            r.add_field :student_acc, "μαθήτρια"
          else
            r.add_field :o, "ο" 
            r.add_field :ton, "τον" 
            r.add_field :ston, "στον" 
            r.add_field :toy, "του" 
            r.add_field :student, "μαθητής"
            r.add_field :student_gen, "μαθητή"
            r.add_field :student_acc, "μαθητή"
          end
        end
      end
      # ssgf.update!( status: SelfServiceGeneratedFile::STATUS[:preparing_2] )
      generatedOdt.generate trgFilename
      ssgf.update!( status: SelfServiceGeneratedFile::STATUS[:created] )
      Rails.logger.info ">> Generated #{trgFilename}."
    end

    #
    # Δημιουργία PDF
    #
    pdfTrgFilename = "certificate.pdf"
    pdfTrgPath = "#{work_dir}/#{pdfTrgFilename}"
    ssgf = SelfServiceGeneratedFile.
      where( self_service_print_job: myJob, path: pdfTrgPath ).first
    if not ssgf
      ssgf = SelfServiceGeneratedFile.new
      ssgf.self_service_print_job = myJob
      ssgf.path = pdfTrgPath
      ssgf.status = SelfServiceGeneratedFile::STATUS[:idle]
      ssgf.save!
    end
    if File.exist? pdfTrgFilename
      Rails.logger.info "Reusing old file #{pdfTrgFilename} for self service job #{myJob.id}"
      # ssgf.update!( status: SelfServiceGeneratedFile::STATUS[:created] )
    else
      ssgf.update!( status: SelfServiceGeneratedFile::STATUS[:preparing_1])
      cmd_output = `libreoffice --convert-to pdf #{trgFilename}`
      if not $?.success?
        ssgf.update!( status: SelfServiceGeneratedFile::STATUS[:internal_error] + " #{cmd_output}" )
        return
      end
      ssgf.update!( status: SelfServiceGeneratedFile::STATUS[:created] )
      Rails.logger.info ">> Generated #{pdfTrgFilename}."
    end

    if myJob.self_service_print_job_spec.send_email and !regenerate_only
      #
      # Αν είναι να στείλουμε και email
      #
      sg_email = SelfGeneratedEmail.
        where( self_service_print_job_spec: myJob.self_service_print_job_spec,
               attachment_path: "#{work_dir}/#{pdfTrgFilename}" ).first

      if not sg_email
        sg_email = SelfGeneratedEmail.new
        sg_email.self_service_print_job_spec = myJob.self_service_print_job_spec
        sg_email.values = myJob.field_values
        sg_email.recipient = myJob.recipient
        sg_email.attachment_path = "#{work_dir}/#{pdfTrgFilename}"
        sg_email.status = "PENDING"
      end

      sg_email.save!

      SentSelfGeneratedEmailJob.
        perform_later( self_generated_email_id: sg_email.id )

      Rails.logger.info ">> Email scheduled to be send"
    end

  end
end
