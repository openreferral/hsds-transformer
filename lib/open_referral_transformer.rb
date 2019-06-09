require "dotenv/load"
require "csv"
require "yaml"
require "pry"
require "zip"
require "zip/zip"
require "rest_client"

class OpenReferralTransformer
  ORGANIZATION_HEADERS = %w(id name alternate_name description email url tax_status tax_id year_incorporated legal_status)
  LOCATION_HEADERS = %w(id organization_id name alternate_name description transportation latitude longitude)
  SERVICE_HEADERS = %w(id organization_id program_id name alternate_name description url email status interpretation_services application_process wait_time fees accreditations licenses)
  PHONE_HEADERS = %w(id location_id service_id organization_id contact_id service_at_location_id number extension type language description)
  ADDRESS_HEADERS = %w(id location_id organization_id attention address_1 city region state_province postal_code country)
  SCHEDULE_HEADERS = %w(id service_id location_id service_at_location_id weekday opens_at closes_at)
  SAL_HEADERS = %w(id service_id location_id description)
  ELIGIBILITIES_HEADERS = %w(id service_id eligibility)
  CONTACTS_HEADERS = %w(id organization_id service_id service_at_location_id name title department email)
  LANGUAGES_HEADERS = %w(id service_id location_id language)
  ACCESSIBILITY_HEADERS = %w(id location_id accessibility details)


  STATE_ABBREVIATIONS = %w(AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY)
  DEFAULT_OUTPUT_DIR = "#{ENV["ROOT_PATH"]}/tmp"
  DEFAULT_INPUT_DIR = "#{ENV["ROOT_PATH"]}/"


  attr_reader :output_organizations_path, :output_locations_path, :output_services_path,
              :mapping, :output_phones_path, :output_addresses_path, :output_schedules_path,
              :output_sal_path, :output_eligibilities_path, :output_contacts_path, :output_languages_path,
              :output_accessibility_path, :valid, :input_dir, :output_dir,
              :include_custom, :generate_pkeys

  def self.run(args)
    new(args).transform
  end

  # TODO validate that incoming data is valid-ish, like unique IDs
  def initialize(args)
    @mapping = parse_mapping(args[:mapping])

    @input_dir = args[:input_dir] || DEFAULT_INPUT_DIR
    @output_dir = args[:output_dir] || DEFAULT_OUTPUT_DIR

    # "include_custom" indicates that the final output CSVs should include the non-HSDS columns that the original input CSVs had
    @include_custom = args[:include_custom]

    # "generate_pkeys" indicates that primary keys for new rows should be generated in this script
    @generate_pkeys

    # TODO DRY this up
    @output_organizations_path = @output_dir + "/organizations.csv"
    @output_locations_path = @output_dir + "/locations.csv"
    @output_services_path = @output_dir + "/services.csv"
    @output_phones_path = @output_dir + "/phones.csv"
    @output_addresses_path = @output_dir + "/addresses.csv"
    @output_schedules_path = @output_dir + "/schedules.csv"
    @output_sal_path = @output_dir + "/service_at_locations.csv"
    @output_eligibilities_path = @output_dir + "/eligibilities.csv"
    @output_contacts_path = @output_dir + "/contacts.csv"
    @output_languages_path = @output_dir + "/languages.csv"
    @output_accessibility_path = @output_dir + "/accessibility_for_disabilities.csv"

    @valid = true

    @phones = []
    @addresses = []
    @schedules = []
    @service_at_locations = []
    @eligibilities = []
    @organizations = []
    @locations = []
    @services = []
    @contacts = []
    @languages = []
    @accessibility_for_disabilities = []
  end

  def transform
    mapping.each do |input_file_name, file_mapping|
      transform_each(input_file_name, file_mapping)
    end

    # write_collected_nested_structures
    format_languages

    write_output_files

    # validate_output

    return self
  end

  def transform_each(input_file_name, file_mapping)
    path = @input_dir + input_file_name
    org_mapping = file_mapping["columns"]


    # Now we want to process each row in a way that allows the row to create multiple objects,
    # including multiple objects from the same rows.
    CSV.foreach(path, headers: true) do |input|
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
            existing_string_value += v.to_s if v

            collected_data[output_field["model"]].merge!(output_field["field"] => existing_string_value)
          else
            if output_field["map"]
              value = output_field["map"][v]
            else
              value = v
            end
            collected_data[output_field["model"]].merge!(output_field["field"] => value) unless value.nil?
          end
        end
      end

      # binding.pry
      # now lets pop each object into its respective instance variable collection so it can be written to the right file
      @organizations << collected_data["organizations"] if collected_data["organizations"] && !collected_data["organizations"].empty?
      @services << collected_data["services"] if collected_data["services"] && !collected_data["services"].empty?
      @locations << collected_data["locations"] if collected_data["locations"] && !collected_data["locations"].empty?
      @addresses << collected_data["addresses"] if collected_data["addresses"] && !collected_data["addresses"].empty?
      @phones << collected_data["phones"] if collected_data["phones"] && !collected_data["phones"].empty?
      @schedules << collected_data["schedules"] if collected_data["schedules"] && !collected_data["schedules"].empty?
      @service_at_locations << collected_data["service_at_locations"] if collected_data["service_at_locations"] && !collected_data["organizations"].empty?
      @contacts << collected_data["contacts"] if collected_data["contacts"] && !collected_data["contacts"].empty?
      @languages << collected_data["languages"] if collected_data["languages"] && !collected_data["languages"].empty?
      @accessibility_for_disabilities << collected_data["accessibility_for_disabilities"] if collected_data["accessibility_for_disabilities"] && !collected_data["accessibility_for_disabilities"].empty?
    end

      # org_mapping.each do |k, v|
      #   if v["model"] == "phones"
      #     # collect_phone_data(phone_key: k, phone_hash: v, input: input)
      #   elsif v["model"] == "postal_address"
      #     collect_address_data(address_key: k, address_hash: v, input: input)
      #   elsif v["model"] == "regular_schedule"
      #     process_regular_schedule_text(schedule_key: k, schedule_hash: v, input: input)
      #   elsif v["model"] == "service_at_locations"
      #     collect_sal_data(sal_key: k, sal_hash: v, input: input)
      #   elsif v["model"] == "eligibilities"
      #     collect_eligibilities_data(eli_key: k, eli_hash: v, input: input)
      #   end
      # end

  end

  private

  def write_output_files
    write_csv(output_organizations_path, ORGANIZATION_HEADERS, @organizations)
    write_csv(output_services_path, SERVICE_HEADERS, @services)
    write_csv(output_locations_path, LOCATION_HEADERS, @locations)
    write_csv(output_phones_path, PHONE_HEADERS, @phones)
    write_csv(output_addresses_path, ADDRESS_HEADERS, @addresses)
    write_csv(output_schedules_path, SCHEDULE_HEADERS, @schedules)
    write_csv(output_sal_path, SAL_HEADERS, @service_at_locations)
    write_csv(output_eligibilities_path, ELIGIBILITIES_HEADERS, @eligibilities)
    write_csv(output_contacts_path, CONTACTS_HEADERS, @contacts)
    write_csv(output_languages_path, LANGUAGES_HEADERS, @languages)
    write_csv(output_accessibility_path, ACCESSIBILITY_HEADERS, @accessibility_for_disabilities)
  end

  def format_languages
    formatted_langs = @languages.each_with_object([]) do |language_row, array|
      langs = language_row["language"].split(",")
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

  # def collect_phone_data(phone_key:, phone_hash:, input:)
  #   key = phone_hash["field"]
  #   phone_row = {}
  #   phone_row[key] = input[phone_key]
  #
  #   foreign_key = phone_hash["foreign_key_name"]
  #   foreign_key_value = phone_hash["foreign_key_value"]
  #   phone_row[foreign_key] = input[foreign_key_value]
  #   phone_data << phone_row
  # end

  def collect_address_data(address_key:, address_hash:, input:)
    key = address_hash["field"]
    address_row = {}
    address = input[address_key]
    postal_code = address.split(//).last(5).join
    postal_code = postal_code.match(/\d{5}/)
    if (postal_code != "")
      address_row["postal_code"] = postal_code
      address = address[0..-7] 
    end
       
    state = address.split(//).last(2).join.upcase
    if STATE_ABBREVIATIONS.include?(state)
      address_row["state_province"] = state
      address = address[0..-5]
    end  
    address_row[key] = address

    foreign_key = address_hash["foreign_key_name"]
    foreign_key_value = address_hash["foreign_key_value"]
    address_row[foreign_key] = input[foreign_key_value]
    address_data << address_row
  end 

  def process_regular_schedule_text(schedule_key:, schedule_hash:, input:)
    if input["Hours of operation"]
      regex_list = input["Hours of operation"].scan(/\S*day: \S*/)
      for regex in regex_list do
        day = regex.split(': ')[0]
        hours = regex.split(': ')[1]
        if hours == "Closed"
          opens_at = nil
          closes_at = nil
        else
          opens_at = hours.split('-')[0]
          closes_at = hours.split('-')[1]
        end
        collect_schedule_data(schedule_key: schedule_key,
            schedule_hash: schedule_hash, input: input,
            day: day, opens_at: opens_at, closes_at: closes_at)
      end
    end
  end

  def collect_schedule_data(schedule_key:, schedule_hash:, input:,
      day:, opens_at:, closes_at:)
    schedule_row = {}
    schedule_row["weekday"] = day
    schedule_row["opens_at"] = opens_at
    schedule_row["closes_at"] = closes_at

    foreign_key = schedule_hash["foreign_key_name"]
    foreign_key_value = schedule_hash["foreign_key_value"]
    schedule_row[foreign_key] = input[foreign_key_value]
    schedule_data << schedule_row
  end

  def collect_sal_data(sal_key:, sal_hash:, input:)
    key = sal_hash["field"]
    sal_row = {}
    sal_row[key] = input[sal_key]

    foreign_key = sal_hash["foreign_key_name"]
    foreign_key_value = sal_hash["foreign_key_value"]
    sal_row[foreign_key] = input[foreign_key_value]
    sal_data << sal_row
  end

  def collect_eligibilities_data(eli_key:, eli_hash:, input:)
    key = eli_hash["field"]
    eli_row = {}
    eli_row[key] = input[eli_key]

    foreign_key = eli_hash["foreign_key_name"]
    foreign_key_value = eli_hash["foreign_key_value"]
    eli_row[foreign_key] = input[foreign_key_value]
    eligibilities_data << eli_row
  end

  def write_collected_nested_structures
    write_csv(output_phones_path, PHONE_HEADERS, phone_data)
    write_csv(output_addresses_path, ADDRESS_HEADERS, address_data)
    write_csv(output_schedules_path, SCHEDULE_HEADERS, schedule_data)
    write_csv(output_sal_path, SAL_HEADERS, sal_data)
    write_csv(output_eligibilities_path, ELIGIBILITIES_HEADERS, eligibilities_data)
  end

  def parse_mapping(mapping_path)
    # uri = URI(mapping_path)
    # file = Net::HTTP.get(uri)
    YAML.load File.read(mapping_path)
    #YAML.load file
  end

  def write_csv(path, headers, data)
    return if data.empty?
    CSV.open(path, 'wb') do |csv|
      csv << headers
      data.each do |row|
        if row.nil?
          binding.pry
        else
          csv << CSV::Row.new(row.keys, row.values).values_at(*headers)
        end

      end
    end
  end

  def validate(filename, type)
    filename = "#{filename}"
    file = File.new(filename, 'rb')
    RestClient.post('http://localhost:1400/validate/csv',
      {"file" => file,
      "type" => type})
    return true
  rescue RestClient::BadRequest
    @valid = false
    return false
  end

  def validate_output
    unless validate(output_organizations_path, "organization")
      puts "Organization data not valid"
    end
    unless validate(output_locations_path, "location")
      puts "Location data not valid"
    end
    unless validate(output_services_path, "service")
      puts "Service data not valid"
    end
    unless validate(output_phones_path, "phone")
      puts "Phone data not valid"
    end
  rescue Errno::ECONNREFUSED
    puts "Can't connect to validation service."
  end

end