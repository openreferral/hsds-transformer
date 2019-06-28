require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/open_referral_transformer"

describe OpenReferralTransformer::Runner do
  describe ".run" do
    context "with valid arguments" do
      it "initiates core transformer as default" do
        args = {
            input_dir: "input/path",
            output_dir: "output/path",
            mapping: "mapping.yaml",
            include_custom: true,
            zip_output: true
        }

        allow(OpenReferralTransformer::BaseTransformer).to receive(:run).with(args)

        OpenReferralTransformer::Runner.run(args)

        expect(OpenReferralTransformer::BaseTransformer).to have_received(:run).with(args)
      end

      it "initiates core transformer as default" do
        base_args = {
          input_dir: "input/path",
          output_dir: "output/path",
          mapping: "mapping.yaml",
          include_custom: true,
          zip_output: true
        }

        args = base_args.merge(custom_transformer: "Open211MiamiTransformer")

        allow(OpenReferralTransformer::Open211MiamiTransformer).to receive(:run).with(base_args)

        OpenReferralTransformer::Runner.run(args)

        expect(OpenReferralTransformer::Open211MiamiTransformer).to have_received(:run).with(base_args)
      end
    end

    context "with invalid arguments" do
      it "raises an exception from an invalid custom" do
        args = {
          input_dir: "input/path",
          output_dir: "output/path",
          mapping: "mapping.yaml",
          include_custom: true,
          zip_output: true,
          custom_transformer: "BadTransformer"
        }

        expect{
          OpenReferralTransformer::Runner.run(args)
        }.to raise_error(OpenReferralTransformer::InvalidCustomTransformerException)
      end
    end
  end
end