module HsdsTransformer
  module Headers
    ORGANIZATIONS_HEADERS = %w(id name alternate_name description email url tax_status tax_id year_incorporated legal_status)
    LOCATIONS_HEADERS = %w(id organization_id name alternate_name description transportation latitude longitude)
    SERVICES_HEADERS = %w(id organization_id program_id name alternate_name description url email status interpretation_services application_process wait_time fees accreditations licenses)
    PHONES_HEADERS = %w(id location_id service_id organization_id contact_id service_at_location_id number extension type language description)
    PHYSICAL_ADDRESSES_HEADERS = %w(id location_id attention address_1 city region state_province postal_code country)
    POSTAL_ADDRESSES_HEADERS = %w(id location_id attention address_1 city region state_province postal_code country)
    SCHEDULES_HEADERS = %w(id service_id location_id service_at_location_id valid_from valid_to dtstart timezone until count wkst freq interval byday byweekno bymonthday byyearday description weekday opens_at closes_at)
    SERVICES_AT_LOCATIONS_HEADERS = %w(id service_id location_id description)
    ELIGIBILITIES_HEADERS = %w(id service_id)
    CONTACTS_HEADERS = %w(id organization_id service_id service_at_location_id name title department email)
    LANGUAGES_HEADERS = %w(id service_id location_id language)
    ACCESSIBILITY_FOR_DISABILITIES_HEADERS = %w(id location_id accessibility details)
    TAXONOMY_TERM_HEADERS = %w(id term description parent_id taxonomy language)
    SERVICE_TAXONOMIES_HEADERS = %w(id service_id taxonomy_id taxonomy_detail)
    SERVICE_AREAS_HEADERS = %w(id service_id service_area description)

    def headers(row, model)
      const_name = "HsdsTransformer::Headers::" + model.upcase + "_HEADERS"
      # TODO make sure valid
      const = Object.const_get(const_name)

      if row && @include_custom
        (const + row.keys).uniq
      else
        const
      end
    end
  end
end