module HsdsTransformer
  class IlaoTransformer < HsdsTransformer::BaseTransformer

    STATE_ABBREVIATIONS = %w(AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY)

    def apply_custom_transformation
      parse_address_data
      # process_regular_schedule_text
    end

    private

    def parse_address_data
      # TODO do this for physical too
      @postal_addresses.each do |address_row|
        address_str = address_row["address_1"]
        postal_code = address_str.split(//).last(5).join
        postal_code = postal_code.match(/\d{5}/)

        if postal_code != ""
          address_row["postal_code"] = postal_code.to_s
          address_str = address_str[0..-7]
        end

        state = address_str.split(//).last(2).join.upcase

        if STATE_ABBREVIATIONS.include?(state)
          address_row["state_province"] = state
          address_str = address_str[0..-5]
        end

        address_row["address_1"] = address_str
      end
    end

    def process_regular_schedule_text(schedule_key:, schedule_hash:, input:)
      if input["Hours of operation"]
        regex_list = input["Hours of operation"].scan(/\S*day: \S*/)
        for regex in regex_list do
          day = regex.split(': ')[0]
          hours = regex.split(': ')[1]
          if hours == "Closed"
            opens_at = nil
            closes_at = nil
          else
            opens_at = hours.split('-')[0]
            closes_at = hours.split('-')[1]
          end
          collect_schedule_data(schedule_key: schedule_key,
                                schedule_hash: schedule_hash, input: input,
                                day: day, opens_at: opens_at, closes_at: closes_at)
        end
      end
    end

    def collect_schedule_data(schedule_key:, schedule_hash:, input:,
                              day:, opens_at:, closes_at:)
      schedule_row = {}
      schedule_row["weekday"] = day
      schedule_row["opens_at"] = opens_at
      schedule_row["closes_at"] = closes_at

      foreign_key = schedule_hash["foreign_key_name"]
      foreign_key_value = schedule_hash["foreign_key_value"]
      schedule_row[foreign_key] = input[foreign_key_value]
      schedule_data << schedule_row
    end

    def collect_sal_data(sal_key:, sal_hash:, input:)
      key = sal_hash["field"]
      sal_row = {}
      sal_row[key] = input[sal_key]

      foreign_key = sal_hash["foreign_key_name"]
      foreign_key_value = sal_hash["foreign_key_value"]
      sal_row[foreign_key] = input[foreign_key_value]
      sal_data << sal_row
    end
  end
end