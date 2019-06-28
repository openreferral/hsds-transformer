module OpenReferralTransformer
  module FilePaths
    DEFAULT_OUTPUT_DIR = "#{ENV["ROOT_PATH"]}/tmp"
    DEFAULT_INPUT_DIR = "#{ENV["ROOT_PATH"]}/"

    attr_reader :input_dir, :output_dir, :output_datapackage_path, :output_data_path, :datapackage_json_path,
                :zipfile_name, :output_organizations_path, :output_locations_path, :output_services_path,
                :output_phones_path, :output_addresses_path, :output_services_at_location_path, :output_eligibilities_path,
                :output_contacts_path, :output_languages_path, :output_accessibility_for_disabilities_path, :output_taxonomies_path,
                :output_service_taxonomies_path, :output_regular_schedules_path

    # TODO DRY this up
    def set_file_paths(args)
      @input_dir = args[:input_dir] || DEFAULT_INPUT_DIR
      @output_dir = args[:output_dir] || DEFAULT_OUTPUT_DIR
      @output_datapackage_path = File.join(output_dir, "datapackage")
      @output_data_path = File.join(output_datapackage_path, "data")
      @zipfile_name = File.join(output_dir, "datapackage.zip")

      @output_organizations_path = output_data_path + "/organizations.csv"
      @output_locations_path = output_data_path + "/locations.csv"
      @output_services_path = output_data_path + "/services.csv"
      @output_phones_path = output_data_path + "/phones.csv"
      @output_addresses_path = output_data_path + "/physical_addresses.csv" # only having physical addresses for now
      @output_services_at_location_path = output_data_path + "/services_at_location.csv"
      @output_eligibilities_path = output_data_path + "/eligibility.csv"
      @output_contacts_path = output_data_path + "/contacts.csv"
      @output_languages_path = output_data_path + "/languages.csv"
      @output_accessibility_for_disabilities_path = output_data_path + "/accessibility_for_disabilities.csv"
      @output_taxonomies_path = output_data_path + "/taxonomy.csv"
      @output_service_taxonomies_path = output_data_path + "/services_taxonomy.csv"
      @output_regular_schedules_path = output_data_path + "/regular_schedules.csv"

      @datapackage_json_path = File.join(ENV["ROOT_PATH"], "lib/datapackage/datapackage.json")
    end
  end
end