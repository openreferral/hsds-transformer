module MiamiProcessing
  def determine_services
    new_services = @services.each do |service|
      # Update the name to remove the org name
      formatted_name = service["name"].split(" - ").last
      service.merge!("name" => formatted_name)

      # Set the org ID as the parent provider id
      if service["parent_provider_id"] != "NULL"
        service.merge!("organization_id" => service["parent_provider_id"])
      end
      service.delete "parent_provider_id"
      service
    end

    @services = new_services
  end

  def remove_child_organizations
    @organizations.reject! do |org|
      org["parent_provider_id"] != "NULL"
    end

    @organizations.each { |org| org.delete("parent_provider_id") }
  end
end