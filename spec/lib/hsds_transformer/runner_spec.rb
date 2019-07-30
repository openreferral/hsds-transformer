require "spec_helper"
require_relative "#{ENV["ROOT_PATH"]}/lib/hsds_transformer"

describe HsdsTransformer::Runner do
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

        allow(HsdsTransformer::BaseTransformer).to receive(:run).with(args)

        HsdsTransformer::Runner.run(args)

        expect(HsdsTransformer::BaseTransformer).to have_received(:run).with(args)
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

        allow(HsdsTransformer::Open211MiamiTransformer).to receive(:run).with(base_args)

        HsdsTransformer::Runner.run(args)

        expect(HsdsTransformer::Open211MiamiTransformer).to have_received(:run).with(base_args)
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
          HsdsTransformer::Runner.run(args)
        }.to raise_error(HsdsTransformer::InvalidCustomTransformerException)
      end
    end
  end
end