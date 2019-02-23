require "dotenv/load"
require "csv"
require "yaml"
require "pry"

class OpenReferralTransformer
  ORGANIZATION_HEADERS = %w(id name alternate_name description email url tax_status tax_id year_incorporated legal_status)
  LOCATION_HEADERS = %w(id organization_id name alternate_name description transportation latitude longitude)
  SERVICE_HEADERS = %w(id organization_id program_id name alternate_name description url email status interpretation_services application_process wait_time fees accreditations licenses)
  PHONE_HEADERS = %w(id location_id service_id organization_id contact_id service_at_location_id number extension type language description)
  ADDRESS_HEADERS = %w(id location_id organization_id attention address_1 city region state_province postal_code country)
   

  attr_reader :organizations_path, :output_organizations_path, :locations_path, :output_locations_path,
              :services_path, :output_services_path, :mapping, :output_phones_path, :output_address_path

  attr_accessor :phone_data, :address_data

  def self.run(args)
    new(args).transform
  end

  def initialize(args)
    @mapping = parse_mapping(args[:mapping])
    @organizations_path = args[:organizations]
    @locations_path = args[:locations]
    @services_path = args[:services]
    @output_organizations_path = "#{ENV["ROOT_PATH"]}/tmp/organizations.csv"
    @output_locations_path = "#{ENV["ROOT_PATH"]}/tmp/locations.csv"
    @output_services_path = "#{ENV["ROOT_PATH"]}/tmp/services.csv"
    @output_phones_path = "#{ENV["ROOT_PATH"]}/tmp/phones.csv"
    @phone_data = []

    @output_address_path = "#{ENV["ROOT_PATH"]}/tmp/addresses.csv"
    @address_data = []
    
  end

  def transform
    transform_organizations if organizations_path
    transform_locations if locations_path
    transform_services if services_path

    write_collected_nested_structures

    return self
  end

  def transform_organizations
    org_mapping = mapping["organizations"]
    org_data = CSV.foreach(organizations_path, headers: true).each_with_object([]) do |input, array|
      row = {}
      valid = true
      org_mapping.each do |k, v|
        if v["required"] == true
          if input[k].nil?
            valid = false
            break
          end
        end
        if v["model"] == "organizations"
          key = v["field"]
          row[key] = input[k]
        elsif v["model"] == "phones"
          collect_phone_data(phone_key: k, phone_hash: v, input: input)
        elsif v["model"] == "postal_address"
          collect_address_data(address_key: k, address_hash: v, input: input)
        end
      end
      if valid
        array << row
      end
    end

    write_csv(output_organizations_path, ORGANIZATION_HEADERS, org_data)
  end

  def transform_locations
    org_mapping = mapping["locations"]
    org_data = CSV.foreach(locations_path, headers: true).each_with_object([]) do |input, array|
      row = {}
      valid = true
      org_mapping.each do |k, v|
        if v["required"] == true
          if input[k].nil?
            valid = false
            break
          end
        end
        if v["model"] == "locations"
          key = v["field"]
          row[key] = input[k]
        elsif v["model"] == "phones"
          collect_phone_data(phone_key: k, phone_hash: v, input: input)
        elsif v["model"] == "postal_address"
          collect_address_data(address_key: k, address_hash: v, input: input)
        end
      end
      if valid
        array << row
      end
    end

    write_csv(output_locations_path, LOCATION_HEADERS, org_data)
  end

  def transform_services
    org_mapping = mapping["services"]
    org_data = CSV.foreach(services_path, headers: true).each_with_object([]) do |input, array|
      row = {}
      valid = true
      org_mapping.each do |k, v|
        if v["required"] == true
          if input[k].nil?
            valid = false
            break
          end
        end
        if v["model"] == "services"
          key = v["field"]
          row[key] = input[k]
        elsif v["model"] == "phones"
          collect_phone_data(phone_key: k, phone_hash: v, input: input)
        elsif v["model"] == "postal_address"
          collect_address_data(address_key: k, address_hash: v, input: input)
        end
      end
      if valid
        array << row
      end
    end

    write_csv(output_services_path, SERVICE_HEADERS, org_data)
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
    puts "Testing"
    key = address_hash["field"]
    address_row = {}
    address_row[key] = input[address_key]

    foreign_key = address_hash["foreign_key_name"]
    foreign_key_value = address_hash["foreign_key_value"]
    address_row[address_key] = input[foreign_key_value]
    address_data << address_row
  end

  def write_collected_nested_structures
    puts address_data
    write_csv(output_phones_path, PHONE_HEADERS, phone_data)
    write_csv(output_address_path, ADDRESS_HEADERS, address_data)
  end

  def parse_mapping(mapping_path)
    YAML.load File.read(mapping_path)
  end

  def write_csv(path, headers, data)
    CSV.open(path, 'wb') do |csv|
      csv << headers
      data.each do |row|
        csv << CSV::Row.new(row.keys, row.values).values_at(*headers)
      end
    end
  end

end