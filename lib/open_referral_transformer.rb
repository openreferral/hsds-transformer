require "dotenv/load"
require "csv"
require "yaml"
require "pry"
require "sinatra"
require "sinatra/base"
require "zip"
require "zip/zip"
#require "net/http"

class Api < Sinatra::Base

  before do
    content_type 'multipart/form-data'
  end

  get "/transform" do
    "Submit your data uri"
  end

  post "/transform" do
    locations_uri = params[:locations]
    organizations_uri = params[:organizations]
    services_uri = params[:services]
    mapping_uri = params[:mapping]

    if mapping_uri.nil?
      halt 422, "A mapping file is required."
    end

    transformer = OpenReferralTransformer.new(
      locations: locations_uri,
      organizations: organizations_uri,
      services: services_uri,
      mapping: mapping_uri)

    transformer.transform

    directory = '\tmp'
    zipfile_name = 'data.zip'
    p directory
    p Dir.glob(File.join(directory, '*'))
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      Dir.glob(File.join(directory, '*')).each do |file|
        zipfile.add(file.sub(directory, ''), file)
      end
    end

    send_file '\data'
  end
end

# uri = URI.parse("http://localhost:4567")

# http = Net::HTTP.new(uri.host, uri.port)
# request = Net::HTTP::Post.new("/v1.1/auth")
# request.add_field('Content-Type', 'application/json')
# request.body = {'credentials' => ''}
#response = http.request(request)



class OpenReferralTransformer
  ORGANIZATION_HEADERS = %w(id name alternate_name description email url tax_status tax_id year_incorporated legal_status)
  LOCATION_HEADERS = %w(id organization_id name alternate_name description transportation latitude longitude)
  SERVICE_HEADERS = %w(id organization_id program_id name alternate_name description url email status interpretation_services application_process wait_time fees accreditations licenses)
  PHONE_HEADERS = %w(id location_id service_id organization_id contact_id service_at_location_id number extension type language description)
  ADDRESS_HEADERS = %w(id location_id organization_id attention address_1 city region state_province postal_code country)
  STATE_ABBREVIATIONS = %w(AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY);

  attr_reader :organizations_path, :output_organizations_path, :locations_path, :output_locations_path,
              :services_path, :output_services_path, :mapping, :output_phones_path, :output_addresses_path

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

    @output_addresses_path = "#{ENV["ROOT_PATH"]}/tmp/addresses.csv"
    @address_data = []
    
  end

  def transform
    transform_each("organizations", organizations_path) if organizations_path
    transform_each("locations", locations_path) if locations_path
    transform_each("services", services_path) if services_path

    write_collected_nested_structures

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

  def write_collected_nested_structures
    write_csv(output_phones_path, PHONE_HEADERS, phone_data)
    write_csv(output_addresses_path, ADDRESS_HEADERS, address_data)
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

end