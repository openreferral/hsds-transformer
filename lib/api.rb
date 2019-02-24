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

    input_folder = "#{ENV["ROOT_PATH"]}/tmp"
    input_filenames = Dir.glob(File.join(directory, '*')).map{|f| f[4..-1]}

    if File.exist?(zipfile_name)
      File.delete(zipfile_name)
    end

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, File.join(input_folder, filename))
      end
    end

    send_file zipfile_name
  end
end


#require "net/http"

# uri = URI.parse("http://localhost:4567")

# http = Net::HTTP.new(uri.host, uri.port)
# request = Net::HTTP::Post.new("/v1.1/auth")
# request.add_field('Content-Type', 'application/json')
# request.body = {'credentials' => ''}
#response = http.request(request)