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

  STATE_ABBREVIATIONS = %w(AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY)
  DEFAULT_OUTPUT_DIR = "#{ENV["ROOT_PATH"]}/tmp"


  attr_reader :organizations_path, :output_organizations_path, :locations_path, :output_locations_path,
              :services_path, :output_services_path, :mapping, :output_phones_path, :output_addresses_path,
              :output_schedules_path, :output_sal_path, :output_eligibilities_path, :valid

  attr_accessor :phone_data, :address_data, :schedule_data, :sal_data, :eligibilities_data

  def self.run(args)
    new(args).transform
  end

  def initialize(args)
    @mapping = parse_mapping(args[:mapping])
    @organizations_path = args[:organizations]
    @locations_path = args[:locations]
    @services_path = args[:services]

    @output_dir = args[:output_dir] || DEFAULT_OUTPUT_DIR

    @output_organizations_path = @output_dir + "/organizations.csv"
    @output_locations_path = @output_dir + "/locations.csv"
    @output_services_path = @output_dir + "/services.csv"
    @output_phones_path = @output_dir + "/phones.csv"
    @output_addresses_path = @output_dir + "/addresses.csv"
    @output_schedules_path = @output_dir + "/schedules.csv"
    @output_sal_path = @output_dir + "/service_at_location.csv"
    @output_eligibilities_path = @output_dir + '/eligibilities.csv'

    @valid = true

    @phone_data = []
    @address_data = []
    @schedule_data = []
    @sal_data = []
    @eligibilities_data = []
  end

  def transform
    transform_each("organizations", organizations_path) if organizations_path
    transform_each("locations", locations_path) if locations_path
    transform_each("services", services_path) if services_path

    write_collected_nested_structures

    validate_output

    return self
  end

  def transform_each(input_csv, path)
    org_mapping = mapping[input_csv]
    org_data = CSV.foreach(path, headers: true).each_with_object([]) do |input, array|
      row = {}
      valid = true
      org_mapping.each do |k, v|
        if v["required"] == true
          if input[k].nil?
            valid = false
            break
          end
        end
        if (v["model"] == input_csv)
          key = v["field"]
          row[key] = input[k]
        elsif v["model"] == "phones"
          collect_phone_data(phone_key: k, phone_hash: v, input: input)
        elsif v["model"] == "postal_address"
          collect_address_data(address_key: k, address_hash: v, input: input)
        elsif v["model"] == "regular_schedule"
          process_regular_schedule_text(schedule_key: k, schedule_hash: v, input: input)
        elsif v["model"] == "service_at_locations"
          collect_sal_data(sal_key: k, sal_hash: v, input: input)
        elsif v["model"] == "eligibilities"
          collect_eligibilities_data(eli_key: k, eli_hash: v, input: input)
        end
      end
      if valid
        array << row
      end
    end

    write_csv(output_organizations_path, ORGANIZATION_HEADERS, org_data)
  end

  private

  def collect_phone_data(phone_key:, phone_hash:, input:)
    key = phone_hash["field"]
    phone_row = {}
    phone_row[key] = input[phone_key]

    foreign_key = phone_hash["foreign_key_name"]
    foreign_key_value = phone_hash["foreign_key_value"]
    phone_row[foreign_key] = input[foreign_key_value]
    phone_data << phone_row
  end

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
    CSV.open(path, 'wb') do |csv|
      csv << headers
      data.each do |row|
        csv << CSV::Row.new(row.keys, row.values).values_at(*headers)
      end
    end
  end

  def validate(filename, type)
    filename = "C:#{filename}"
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