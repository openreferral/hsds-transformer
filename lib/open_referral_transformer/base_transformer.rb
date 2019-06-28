module OpenReferralTransformer
  class BaseTransformer
    include OpenReferralTransformer::Headers
    include OpenReferralTransformer::FilePaths

    STATE_ABBREVIATIONS = %w(AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY)

    attr_reader :mapping, :include_custom

    def self.run(args)
      new(args).transform
    end

    # TODO validate that incoming data is valid-ish, like unique IDs
    def initialize(args)
      @mapping = parse_mapping(args[:mapping])

      # "include_custom" indicates that the final output CSVs should include the non-HSDS columns that the original input CSVs had
      @include_custom = args[:include_custom]
      @zip_output = args[:zip_output]

      # All the HSDS models we currently support
      @phones = []
      @addresses = []
      @services_at_location = []
      @eligibilities = []
      @organizations = []
      @locations = []
      @services = []
      @contacts = []
      @languages = []
      @accessibility_for_disabilities = []
      @taxonomies = []
      @service_taxonomies = []
      @regular_schedules = []

      set_file_paths(args)
    end

    def transform
      # Initial transformation into HSDS
      mapping.each do |input_file_name, file_mapping|
        transform_file(input_file_name, file_mapping)
      end

      # HSDS additional formatting
      singletonize_languages

      apply_custom_transformation

      # make data dir for these files
      Dir.mkdir(output_datapackage_path) unless Dir.exists?(output_datapackage_path)
      Dir.mkdir(output_data_path) unless Dir.exists?(output_data_path)

      # Write the data to CSV files
      write_output_files

      zip_output if @zip_output

      return self
    end

    def transform_file(input_file_name, file_mapping)
      path = @input_dir + input_file_name
      org_mapping = file_mapping["columns"]


      # Now we want to process each row in a way that allows the row to create multiple objects,
      # including multiple objects from the same rows.
      CSV.foreach(path, headers: true) do |input|
        collected_data = hsds_objects_from_row(input, org_mapping)
        collect_into_ivars(collected_data)
      end
    end


    # This is defined in custom transformer if there is one
    def apply_custom_transformation
    end

    private

    def hsds_objects_from_row(input, org_mapping)
      collected_data = {}

      # k is the input field_name
      # org_mapping[k] gives us the array of output fields
      input.each do |k,v|
        # turn this into array to be backwards compatible
        output_fields = org_mapping[k].is_a?(Array) ? org_mapping[k] : [org_mapping[k]]

        # now lets collect each object
        output_fields.compact.each do |output_field|

          # collected_data[output_field["model"]] should make it such that collected_data = { "organizations" => {} }
          collected_data[output_field["model"]] ||= {}

          # Append all string fields marked as "append" to single output field
          if output_field["append"]
            existing_string_value = collected_data[output_field["model"]][output_field["field"]] || ""
            existing_string_value += v.to_s unless null_type(v)

            collected_data[output_field["model"]].merge!(output_field["field"] => existing_string_value)
          else
            if output_field["map"]
              value = output_field["map"][v]
            else
              value = v
            end
            safe_val = null_type(value) ? nil : value
            # TODO provide default too
            collected_data[output_field["model"]].merge!(output_field["field"] => safe_val)
          end
        end
      end
      collected_data
    end

    def null_type(string)
      string.nil? || string.downcase.strip == "null"
    end

    # TODO dry this up
    def write_output_files
      write_csv(output_organizations_path, headers(@organizations.first, "organization"), @organizations)
      write_csv(output_services_path, headers(@services.first, "service"), @services)
      write_csv(output_locations_path, headers(@locations.first, "location"), @locations)
      write_csv(output_phones_path, headers(@phones.first, "phone"), @phones)
      write_csv(output_addresses_path, headers(@addresses.first, "address"), @addresses)
      write_csv(output_sal_path, headers(@services_at_location.first, "sal"), @services_at_location)
      write_csv(output_eligibilities_path, headers(@eligibilities.first, "eligibility"), @eligibilities)
      write_csv(output_contacts_path, headers(@contacts.first, "contact"), @contacts)
      write_csv(output_languages_path, headers(@languages.first, "language"), @languages)
      write_csv(output_accessibility_path, headers(@accessibility_for_disabilities.first, "accessibility"), @accessibility_for_disabilities)
      write_csv(output_taxonomy_path, headers(@taxonomies.first, "taxonomy"), @taxonomies)
      write_csv(output_service_taxonomy_path, headers(@service_taxonomies.first, "service_taxonomy"), @service_taxonomies)
      write_csv(output_regular_schedules_path, headers(@regular_schedules.first, "regular_schedule"), @regular_schedules)
    end

    def zip_output
      input_data_files = Dir.glob(File.join(output_data_path, '**/*'))


      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        # Add databpackage.json
        zipfile.add("datapackage.json", datapackage_json_path)

        # Add data files
        input_data_files.each do |file_path|
          zipped_name = "data/" + File.basename(file_path)
          zipfile.add(zipped_name, file_path)
        end
      end
    end

    # TODO dry this up
    # Now let's pop each object into its respective instance variable collection to be written to the right file
    def collect_into_ivars(collected_data)
      @organizations << collected_data["organizations"] if collected_data["organizations"] && !collected_data["organizations"].empty?
      @services << collected_data["services"] if collected_data["services"] && !collected_data["services"].empty?
      @locations << collected_data["locations"] if collected_data["locations"] && !collected_data["locations"].empty?
      @addresses << collected_data["addresses"] if collected_data["addresses"] && !collected_data["addresses"].empty?
      @phones << collected_data["phones"] if collected_data["phones"] && !collected_data["phones"].empty?
      @services_at_location << collected_data["service_at_locations"] if collected_data["service_at_locations"] && !collected_data["service_at_locations"].empty?
      @contacts << collected_data["contacts"] if collected_data["contacts"] && !collected_data["contacts"].empty?
      @languages << collected_data["languages"] if collected_data["languages"] && !collected_data["languages"].empty?
      @accessibility_for_disabilities << collected_data["accessibility_for_disabilities"] if collected_data["accessibility_for_disabilities"] && !collected_data["accessibility_for_disabilities"].empty?
      @taxonomies << collected_data["taxonomies"] if collected_data["taxonomies"] && !collected_data["taxonomies"].empty?
      @service_taxonomies << collected_data["service_taxonomies"] if collected_data["service_taxonomies"] && !collected_data["service_taxonomies"].empty?
      @regular_schedules << collected_data["regular_schedules"] if collected_data["regular_schedules"] && !collected_data["regular_schedules"].empty?
    end

    def singletonize_languages
      formatted_langs = @languages.each_with_object([]) do |language_row, array|
        langs = language_row["language"].to_s.split(",")
        if langs.size > 1
          langs.each do |lang|
            array << language_row.clone.merge("language" => lang.strip)
          end
        else
          array << language_row
        end
      end
      @languages = formatted_langs
    end

    def parse_mapping(mapping_path)
      if mapping_path[0..3] == "http"
        uri = URI(mapping_path)
        file = Net::HTTP.get(uri)
        YAML.load file
      else
        YAML.load File.read(mapping_path)
      end
    end

    # This also dedupes data by calling `uniq` on each collection before writing
    def write_csv(path, headers, data)
      return if data.empty?
      CSV.open(path, 'wb') do |csv|
        csv << headers
        data.uniq.each do |row|
          csv << CSV::Row.new(row.keys, row.values).values_at(*headers) unless row.values.all?(nil)
        end
      end
    end
  end
end