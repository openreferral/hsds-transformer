module OpenReferralTransformer
  module Headers
    ORGANIZATION_HEADERS = %w(id name alternate_name description email url tax_status tax_id year_incorporated legal_status)
    LOCATION_HEADERS = %w(id organization_id name alternate_name description transportation latitude longitude)
    SERVICE_HEADERS = %w(id organization_id program_id name alternate_name description url email status interpretation_services application_process wait_time fees accreditations licenses)
    PHONE_HEADERS = %w(id location_id service_id organization_id contact_id service_at_location_id number extension type language description)
    ADDRESS_HEADERS = %w(id location_id organization_id attention address_1 city region state_province postal_code country)
    REGULAR_SCHEDULE_HEADERS = %w(id service_id location_id service_at_location_id weekday opens_at closes_at)
    SAL_HEADERS = %w(id service_id location_id description)
    ELIGIBILITY_HEADERS = %w(id service_id eligibility)
    CONTACT_HEADERS = %w(id organization_id service_id service_at_location_id name title department email)
    LANGUAGE_HEADERS = %w(id service_id location_id language)
    ACCESSIBILITY_HEADERS = %w(id location_id accessibility details)
    TAXONOMY_HEADERS = %w(id name parent_id parent_name vocabulary)
    SERVICE_TAXONOMY_HEADERS = %w(id service_id taxonomy_id taxonomy_detail)

    def headers(row, model)
      const_name = "OpenReferralTransformer::Headers::" + model.upcase + "_HEADERS"
      # TODO make sure valid
      const = Object.const_get(const_name)

      if row && @include_custom
        (row.keys + const).uniq
      else
        const
      end
    end
  end
end