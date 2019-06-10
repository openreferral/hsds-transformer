module FilePaths
  attr_reader :output_organizations_path, :output_locations_path, :output_services_path,
              :output_phones_path, :output_addresses_path, :output_schedules_path,
              :output_sal_path, :output_eligibilities_path, :output_contacts_path,
              :output_languages_path, :output_accessibility_path, :output_taxonomy_path,
              :output_service_taxonomy_path

  # TODO DRY this up
  def set_file_paths
    @output_organizations_path = @output_dir + "/organizations.csv"
    @output_locations_path = @output_dir + "/locations.csv"
    @output_services_path = @output_dir + "/services.csv"
    @output_phones_path = @output_dir + "/phones.csv"
    @output_addresses_path = @output_dir + "/physical_addresses.csv" # only having physical addresses for now
    @output_schedules_path = @output_dir + "/regular_schedules.csv" # only regular schedules for now
    @output_sal_path = @output_dir + "/services_at_location.csv"
    @output_eligibilities_path = @output_dir + "/eligibility.csv"
    @output_contacts_path = @output_dir + "/contacts.csv"
    @output_languages_path = @output_dir + "/languages.csv"
    @output_accessibility_path = @output_dir + "/accessibility_for_disabilities.csv"
    @output_taxonomy_path = @output_dir + "/taxonomy.csv"
    @output_service_taxonomy_path = @output_dir + "/services_taxonomy.csv"
  end
end