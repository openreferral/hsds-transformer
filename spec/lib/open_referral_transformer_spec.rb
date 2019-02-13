require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/open_referral_transformer"

describe OpenReferralTransformer do
  xit "transforms a group of CSVs into valid datapackage.json"

  it "converts an organizations file into valid HSDS organizations model" do
    organizations_file_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/input/organizations.csv"
    mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/mapping.yaml"
    transformer = OpenReferralTransformer.run(organizations: organizations_file_path, mapping: mapping_path)

    output_file = CSV.read transformer.output_organizations_path
    fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/output/resources/organizations.csv"
    expect(output_file).to eq(fixture)
  end
end