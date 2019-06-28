require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/open_referral_transformer"

describe OpenReferralTransformer::IlaoTransformer do
  it "parses and creates address rows correctly" do
    input_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/custom/ilao/input/"
    mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/custom/ilao/mapping.yaml"
    transformer = OpenReferralTransformer::IlaoTransformer.new(
      input_path: input_path,
      mapping: mapping_path,
    )

    transformer.transform

    output_file = CSV.read transformer.output_postal_addresses_path
    fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/custom/ilao/output/postal_addresses.csv"
    expect(output_file).to eq(fixture)
  end

  # TODO
  xit "parses and creates schedule rows correctly" do
    input_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/custom/ilao/input/"
    mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/custom/ilao/mapping.yaml"
    transformer = OpenReferralTransformer::BaseTransformer.new(
        input_path: input_path,
        mapping: mapping_path
    )

    transformer.transform

    output_file = CSV.read transformer.output_regular_schedules_path
    fixture = CSV.read "#{ENV["ROOT_PATH"]}/spec/fixtures/custom/ilao/output/regular_schedules.csv"
    expect(output_file).to eq(fixture)
  end
end