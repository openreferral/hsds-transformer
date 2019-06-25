require "sinatra"
require "sinatra/base"
require_relative "../lib/open_referral_transformer"

class Api < Sinatra::Base

  before do
    content_type 'multipart/form-data'
  end

  get "/transform" do
    "Submit your data uri"
  end

  post "/transform" do
    input_path = params[:input_path]
    mapping_uri = params[:mapping]
    include_custom = params[:include_custom]

    if mapping_uri.nil?
      halt 422, "A mapping file is required."
    end

    transformer = OpenReferralTransformer.new(
        input_path: input_path,
        mapping: mapping_uri,
        include_custom: include_custom,
        zip_output: true,
    )

    transformer.transform

    send_file transformer.zipfile_name
  end
end


#require "net/http"

# uri = URI.parse("http://localhost:4567")

# http = Net::HTTP.new(uri.host, uri.port)
# request = Net::HTTP::Post.new("/v1.1/auth")
# request.add_field('Content-Type', 'application/json')
# request.body = {'credentials' => ''}
#response = http.request(request)