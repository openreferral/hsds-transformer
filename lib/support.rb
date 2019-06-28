# TODO implement validation
module Support
  def validate(filename, type)
    filename = "#{filename}"
    file = File.new(filename, 'rb')
    RestClient.post('http://localhost:1400/validate/csv',
                    {"file" => file,
                     "type" => type})
    return true
  rescue RestClient::BadRequest
    @valid = false
    return false
  end

  def validate_output
    unless validate(output_organizations_path, "organization")
      puts "Organization data not valid"
    end
    unless validate(output_locations_path, "location")
      puts "Location data not valid"
    end
    unless validate(output_services_path, "service")
      puts "Service data not valid"
    end
    unless validate(output_phones_path, "phone")
      puts "Phone data not valid"
    end
  rescue Errno::ECONNREFUSED
    puts "Can't connect to validation service."
  end
end