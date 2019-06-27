require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/open_referral_transformer"

ORGANIZATION_HEADERS = %w(id name alternate_name description email url tax_status tax_id year_incorporated legal_status)
LOCATION_HEADERS = %w(id organization_id name alternate_name description transportation latitude longitude)
SERVICE_HEADERS = %w(id organization_id program_id name alternate_name description url email status interpretation_services application_process wait_time fees accreditations licenses)
PHONE_HEADERS = %w(id location_id service_id organization_id contact_id service_at_location_id number extension type language description)
OUTPUT_DIRECTORY_PATH = OpenReferralTransformer::FilePaths::DEFAULT_OUTPUT_DIR


describe OpenReferralTransformer do

  describe ".run" do
    xit "transforms a group of CSVs into valid datapackage.json and linked resources"
  end

  describe "#transform" do
    it "creates phone records for phone numbers mapped in input csv" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer::Core.new(
        input_dir: input_dir,
        mapping: mapping_path
      )

      transformer.transform
      output_file = CSV.read transformer.output_phones_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/phones.csv"
      expect(output_file).to eq(fixture)
    end

    # TODO add distinction between postel and physical addresses
    xit "creates address records for address numbers mapped in input csv" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer::Core.new(
          input_dir: input_dir,
          mapping: mapping_path
      )

      transformer.transform

      output_file = CSV.read transformer.output_addresses_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/addresses.csv"
      expect(output_file).to eq(fixture)
    end

    # TODO add parsing back with custom processing
    xit "creates schedule records for schedules mapped in input csv" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer::Core.new(
          input_dir: input_dir,
          mapping: mapping_path
      )

      transformer.transform

      output_file = CSV.read transformer.output_regular_schedules_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/schedules.csv"
      expect(output_file).to eq(fixture)
    end
  end

  describe "#transform_organizations" do
    it "converts an organizations file into valid HSDS organizations data" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer::Core.new(
          input_dir: input_dir,
          mapping: mapping_path
      )

      transformer.transform

      output_file = CSV.read transformer.output_organizations_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/organizations.csv"
      expect(output_file).to eq(fixture)
    end
  end

  describe "#transform_locations" do
    it "converts a locations file into valid HSDS locations data" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer::Core.new(
          input_dir: input_dir,
          mapping: mapping_path
      )

      transformer.transform

      output_file = CSV.read transformer.output_locations_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/locations.csv"
      expect(output_file).to eq(fixture)
    end
  end

  describe "#transform_services" do
    # TODO implement required fields
    xit "converts a services file into valid HSDS services data" do
      input_dir = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer::Core.new(
          input_dir: input_dir,
          mapping: mapping_path
      )

      output_file = CSV.read transformer.output_services_path

      transformer.transform
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/services.csv"
      expect(output_file).to eq(fixture)
    end
  end
end