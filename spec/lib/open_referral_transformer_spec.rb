require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/open_referral_transformer"

describe OpenReferralTransformer do

  describe ".run" do
    xit "transforms a group of CSVs into valid datapackage.json and linked resources"
  end

  describe "#transform" do
    it "creates phone records for phone numbers mapped in input csv" do
      locations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/locations.csv"
      organizations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/organizations.csv"
      services_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/services.csv"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer.new(
        locations: locations_file_path,
        organizations: organizations_file_path,
        services: services_file_path,
        mapping: mapping_path
      )

      transformer.transform

      output_file = CSV.read transformer.output_phones_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/phones.csv"
      expect(output_file).to eq(fixture)
    end

    it "creates address records for address numbers mapped in input csv" do
      locations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/locations.csv"
      organizations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/organizations.csv"
      services_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/services.csv"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer.new(
        locations: locations_file_path,
        organizations: organizations_file_path,
        services: services_file_path,
        mapping: mapping_path
      )

      transformer.transform

      output_file = CSV.read transformer.output_addresses_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/addresses.csv"
      expect(output_file).to eq(fixture)
    end

    it "creates eligibility records for eligibility data mapped in input csv" do
      locations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/locations.csv"
      organizations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/organizations.csv"
      services_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/services.csv"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer.new(
        locations: locations_file_path,
        organizations: organizations_file_path,
        services: services_file_path,
        mapping: mapping_path
      )

      transformer.transform

      output_file = CSV.read transformer.output_eligibility_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/eligibility.csv"
      expect(output_file).to eq(fixture)
    end
  end

  describe "#transform_organizations" do
    it "converts an organizations file into valid HSDS organizations data" do
      organizations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/organizations.csv"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer.new(organizations: organizations_file_path, mapping: mapping_path)

      transformer.transform_each("organizations",organizations_file_path)

      output_file = CSV.read transformer.output_organizations_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/organizations.csv"
      expect(output_file).to eq(fixture)
    end
  end

  describe "#transform_locations" do
    it "converts a locations file into valid HSDS locations data" do
      locations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/locations.csv"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer.new(locations: locations_file_path, mapping: mapping_path)

      transformer.transform_each("locations", locations_file_path)

      output_file = CSV.read transformer.output_locations_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/locations.csv"
      expect(output_file).to eq(fixture)
    end
  end

  describe "#transform_services" do
    it "converts a services file into valid HSDS services data" do
      services_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/services.csv"
      mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
      transformer = OpenReferralTransformer.new(services: services_file_path, mapping: mapping_path)

      transformer.transform_each("services",services_file_path)

      output_file = CSV.read transformer.output_services_path
      fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/services.csv"
      expect(output_file).to eq(fixture)
    end
  end
end
