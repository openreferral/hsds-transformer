require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/hsds_transformer"

ORGANIZATION_HEADERS = %w(id name alternate_name description email url tax_status tax_id year_incorporated legal_status)
LOCATION_HEADERS = %w(id organization_id name alternate_name description transportation latitude longitude)
SERVICE_HEADERS = %w(id organization_id program_id name alternate_name description url email status interpretation_services application_process wait_time fees accreditations licenses)
PHONE_HEADERS = %w(id location_id service_id organization_id contact_id service_at_location_id number extension type language description)
OUTPUT_DIRECTORY_PATH = HsdsTransformer::FilePaths::DEFAULT_OUTPUT_PATH


describe HsdsTransformer::BaseTransformer do

  describe ".run" do
    xit "transforms a group of CSVs into valid datapackage.json and linked resources"
  end

  # This can probably be better
  describe "#transform" do
    it "transforms CSV input data into HSDS-compliant CSVs" do
      input_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/input/"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/mapping.yaml"
      transformer = HsdsTransformer::BaseTransformer.new(
        input_path: input_path,
        mapping: mapping_path
      )

      transformer.transform

      output_phones = CSV.read transformer.output_phones_path
      phones_fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/data/phones.csv"
      expect(output_phones).to eq(phones_fixture)

      output_organizations = CSV.read transformer.output_organizations_path
      organizations_fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/data/organizations.csv"
      expect(output_organizations).to eq(organizations_fixture)

      output_locations = CSV.read transformer.output_locations_path
      locations_fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/data/locations.csv"
      expect(output_locations).to eq(locations_fixture)

      # TODO implement required fields
      output_services = CSV.read transformer.output_services_path
      services_fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/data/services.csv"
      expect(output_services).to eq(services_fixture)

      output_postal_addresses = CSV.read transformer.output_postal_addresses_path
      postal_addresses_fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/data/postal_addresses.csv"
      expect(output_postal_addresses).to eq(postal_addresses_fixture)

      output_regular_schedules = CSV.read transformer.output_regular_schedules_path
      regular_schedules_fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/data/regular_schedules.csv"
      expect(output_regular_schedules).to eq(regular_schedules_fixture)

      output_services_at_location = CSV.read transformer.output_services_at_locations_path
      services_at_location_fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/data/services_at_location.csv"
      expect(output_services_at_location).to eq(services_at_location_fixture)

      output_eligibility = CSV.read transformer.output_eligibilities_path
      eligibility_fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/data/eligibility.csv"
      expect(output_eligibility).to eq(eligibility_fixture)
    end

    it "infers datapackage.json from input data when path is safe" do
      input_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/input/"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/mapping.yaml"
      transformer = HsdsTransformer::BaseTransformer.new(
          input_path: input_path,
          mapping: mapping_path
      )

      transformer.transform

      output_datapackage_json = File.read transformer.output_datapackage_file_path
      datapackage_json_fixture = File.read "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/output/datapackage.json"
      expect(output_datapackage_json).to eq(datapackage_json_fixture)
    end

    xit "uses default datapackage.json when path is unsafe" do

    end
  end
end