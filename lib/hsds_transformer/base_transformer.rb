module HsdsTransformer
  class BaseTransformer
    include HsdsTransformer::Headers
    include HsdsTransformer::FilePaths

    attr_reader :mapping, :include_custom

    SUPPORTED_HSDS_MODELS = %w(organizations services locations physical_addresses postal_addresses phones schedules taxonomy_term accessibility_for_disabilities contacts languages eligibilities services_at_locations service_areas)

    def self.run(args)
      new(args).transform
    end

    # TODO validate that incoming data is valid-ish, like unique IDs
    def initialize(args)
      @mapping = parse_mapping(args[:mapping])

      @include_custom = args[:include_custom]
      @zip_output = args[:zip_output]

      SUPPORTED_HSDS_MODELS.each do |model|
        var_name = "@" + model
        instance_variable_set(var_name, [])
      end

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

      # make data path for these files
      Dir.mkdir(output_datapackage_path) unless Dir.exists?(output_datapackage_path)
      Dir.mkdir(output_data_path) unless Dir.exists?(output_data_path)

      # Write the data to CSV files
      write_output_files

      zip_output if @zip_output

      return self
    end

    def transform_file(input_file_name, file_mapping)
      path = @input_path + input_file_name
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
            collected_data[output_field["model"]].merge!(output_field["field"] => safe_val)
          end
        end
      end
      collected_data
    end

    def null_type(string)
      string.nil? || string.downcase.strip == "null"
    end

    # Now let's pop each object into its respective instance variable collection to be written to the right file
    def collect_into_ivars(collected_data)
      SUPPORTED_HSDS_MODELS.each do |model|
        collection_ivar(model) << collected_data[model] if collected_data[model] && !collected_data[model].empty?
      end
    end

    def collection_ivar(model)
      var_name = "@" + model
      instance_variable_get(var_name)
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

    def write_output_files
      SUPPORTED_HSDS_MODELS.each do |model|
        path_var = instance_variable_get "@output_#{model}_path"
        write_csv path_var, headers(collection_ivar(model).first, model), collection_ivar(model)
      end
      write_datapackage_json
    end

    def write_datapackage_json
      package = DataPackage::Package.new

      # Is the output path in the file tree of the current directory? If so, we can work with it; if not, we can't.
      # Due to "safe" file path requirements in the datapackage-rb library
      path_chunks = output_datapackage_path.split(Dir.pwd)
      if path_chunks[0] == ""
        base_dir, remaining_path = parse_path(path_chunks)
        descriptor = package.infer(directory: "#{remaining_path}/data", base_path: base_dir)
        content_to_write = descriptor.to_json
      else
        content_to_write = File.read(default_datapackage_json_path)
      end
      File.open(output_datapackage_file_path, "wb") { |f| f.write(content_to_write) }
    end

    # Returns for example: ['tmp', 'input/data']
    def parse_path(path_chunks)
      path = path_chunks[1]
      subpath_chunks = path.split("/")
      base_dir = subpath_chunks[1]
      remaining_path = subpath_chunks[2..-1].join("/")
      [base_dir, remaining_path]
    end

    def zip_output
      input_data_files = Dir.glob(File.join(output_data_path, "**/*"))


      File.delete(zipfile_name) if File.exists?(zipfile_name)

      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|

        # Add databpackage.json
        zipfile.add("datapackage.json", output_datapackage_file_path)

        # Add data files
        input_data_files.each do |file_path|
          zipped_name = "data/" + File.basename(file_path)
          zipfile.add(zipped_name, file_path)
        end
      end
    end

    # This also dedupes data by calling `uniq` on each collection before writing
    def write_csv(path, headers, data)
      return if data.empty?
      CSV.open(path, 'wb') do |csv|
        csv << headers
        data.uniq.each do |row|
          csv << CSV::Row.new(row.keys, row.values).values_at(*headers) unless row.values.all? { |v| v.nil? || v.strip == '' }
        end
      end
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
  end
end