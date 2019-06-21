module FilePaths
  attr_reader :output_organizations_path, :output_locations_path, :output_services_path,
              :output_phones_path, :output_addresses_path,
              :output_sal_path, :output_eligibilities_path, :output_contacts_path,
              :output_languages_path, :output_accessibility_path, :output_taxonomy_path,
              :output_service_taxonomy_path, :output_regular_schedules_path

  # TODO DRY this up
  def set_file_paths
    @output_organizations_path = output_data_path + "/organizations.csv"
    @output_locations_path = output_data_path + "/locations.csv"
    @output_services_path = output_data_path + "/services.csv"
    @output_phones_path = output_data_path + "/phones.csv"
    @output_addresses_path = output_data_path + "/physical_addresses.csv" # only having physical addresses for now
    @output_sal_path = output_data_path + "/services_at_location.csv"
    @output_eligibilities_path = output_data_path + "/eligibility.csv"
    @output_contacts_path = output_data_path + "/contacts.csv"
    @output_languages_path = output_data_path + "/languages.csv"
    @output_accessibility_path = output_data_path + "/accessibility_for_disabilities.csv"
    @output_taxonomy_path = output_data_path + "/taxonomy.csv"
    @output_service_taxonomy_path = output_data_path + "/services_taxonomy.csv"
    @output_regular_schedules_path = output_data_path + "/regular_schedules.csv"
  end
end