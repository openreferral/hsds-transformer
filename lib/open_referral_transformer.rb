require "dotenv/load"
require "csv"
require "yaml"
require "pry"

class OpenReferralTransformer
  ORGANIZATION_HEADERS = %w(id name alternate_name description email url tax_status tax_id year_incorporated legal_status)

  attr_reader :organizations_path, :output_organizations_path, :mapping

  def self.run(args)
    new(args).transform
  end

  def initialize(args)
    @mapping = parse_mapping(args[:mapping])
    @organizations_path = args[:organizations]
    @output_organizations_path = "#{ENV["ROOT_PATH"]}/tmp/organizations.csv"
  end

  def transform
    transform_organizations

    return self
  end

  private

  def transform_organizations
    org_mapping = mapping["organizations"]
    org_data = CSV.foreach(organizations_path, headers: true).each_with_object([]) do |input, array|
      row = {}
      org_mapping.each do |k, v|
        if v["model"] == "organizations"
          key = v["field"]
          row[key] = input[k]
        end
      end
      array << row
    end

    write_csv(output_organizations_path, ORGANIZATION_HEADERS, org_data)
  end

  def parse_mapping(mapping_path)
    YAML.load File.read(mapping_path)
  end

  def write_csv(path, headers, data)
    CSV.open(path, 'wb') do |csv|
      csv << headers
      data.each do |row|
        csv << CSV::Row.new(row.keys, row.values).values_at(*headers)
      end
    end
  end

end