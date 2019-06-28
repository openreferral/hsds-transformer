require "spec_helper"
require "rack/test"
require_relative "#{ENV["ROOT_PATH"]}/lib/api"

describe Api do
  include Rack::Test::Methods

  def app
    Api
  end

  describe "post /transform" do
    context "valid request" do
      it "returns a zip file" do
        # TODO Stub this test out

        input_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/input/"
        mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/mapping.yaml"

        params = {
          input_path: input_path,
          mapping: mapping_path,
        }

        post "/transform", params

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq IO.binread("#{ENV["ROOT_PATH"]}/tmp/datapackage.zip")
      end

      context "with valid custom transformer param" do
        it "returns a zip file" do
          # TODO Stub this test out

          input_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/input/"
          mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/mapping.yaml"

          params = {
            custom_transformer: "Open211MiamiTransformer",
            input_path: input_path,
            mapping: mapping_path,
          }

          post "/transform", params

          expect(last_response.status).to eq(200)
          expect(last_response.body).to eq IO.binread("#{ENV["ROOT_PATH"]}/tmp/datapackage.zip")
        end
      end
    end

    context "invalid request" do
      context "no mapping param provided" do
        it "returns an error status" do
          input_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/input/"

          params = {
            input_path: input_path,
          }

          post "/transform", params

          expect(last_response.status).to eq(422)
        end
      end

      context "no input_path param provided" do
        it "returns an error status" do
          mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/mapping.yaml"

          params = {
            mapping: mapping_path,
          }

          post "/transform", params

          expect(last_response.status).to eq(422)
        end
      end

      context "wth invalid custom transformer param" do
        it "returns an error status" do
          # TODO Change this to 422

          input_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/input/"
          mapping_path = "#{ENV["ROOT_PATH"]}/spec/fixtures/base_transformer/mapping.yaml"

          params = {
              custom_transformer: "BadTransformer",
              input_path: input_path,
              mapping: mapping_path,
          }

          post "/transform", params

          expect(last_response.status).to eq(500)
        end
      end
    end
  end
end