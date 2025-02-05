class AddSubjectBodyToEmailjobspecs < ActiveRecord::Migration[7.0]
  def change
    add_column :email_job_specs, :subject, :string   #, default: "Βεβαίωση"
    add_column :email_job_specs, :body, :text        #BLOBs TEXTs GEOMETRIEs and JSONs can't have defaults in MySQL, default: "Η βεβαίωσή σας βρίσκεται συνημμένη στο παρών email.\n\nΜε εκτίμηση\n\n"
  end
end
