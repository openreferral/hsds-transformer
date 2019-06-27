module OpenReferralTransformer
  module Custom
    class Open211MiamiTransformer < OpenReferralTransformer::Core
      WEEKDAYS = %w(Monday Tuesday Wednesday Thursday Friday)
      ALL_DAYS = %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
      DAY_MAPPING = {
          "mon" => "Monday",
          "tue" => "Tuesday",
          "wed" => "Wednesday",
          "thu" => "Thursday",
          "fri" => "Friday",
          "sat" => "Saturday",
          "sun" => "Sunday",
      }

      def apply_custom_transformation
        remove_child_organizations
        determine_services
        parse_regular_schedules_text
      end

      def determine_services
        new_services = @services.each do |service|
          # Update the name to remove the org name
          formatted_name = service["name"].to_s.split(" - ").last
          service.merge!("name" => formatted_name)

          # Set the org ID as the parent provider id
          if service["parent_provider_id"] != ""
            service.merge!("organization_id" => service["parent_provider_id"])
          end
          service.delete "parent_provider_id"
          service
        end

        @services = new_services
      end

      # TODO figure out what to do with 24 hour text
      # TODO add IDs
      def parse_regular_schedules_text
        new_schedules = @regular_schedules.each_with_object([]) do |sched_row, new_sheds|
          # Schedule times and tidbits are mostly separated by a newline
          sched_options = sched_row["original_text"].split("\n")

          sched_options.each do |opt|
            opt_days = find_days(opt)
            if all_weekdays?(opt_days)
              sched_days = WEEKDAYS
            elsif single_days?(opt_days)
              sched_days = single_days(opt_days)
            else
              sched_days = []
            end

            sched_days.each do |day|
              new_sheds << new_sched_row(day, opt, sched_row)
            end
          end
        end

        @regular_schedules = new_schedules
      end

      def find_days(opt_string)
        strings = opt_string.split(", ")[1..-1].compact.flatten
        strings.map(&:downcase)
      end

      def all_weekdays?(days)
        days == ["mon-fri"]
      end

      def single_days?(days)
        !single_days(days).empty?
      end

      def single_days(days)
        DAY_MAPPING.select{ |day| days.include? day }.values
      end

      def hours(opt)
        range = opt.split(", ")[0]
        times = range.split("-")
        return unless times.size == 2

        open = clean_time(times[0])
        close = clean_time(times[1])

        [open, close]
      end

      # Finds the time in strings like "Admin:\\n9:00am", "9am", "9:0a", "10:00pm"
      def clean_time(time)
        /\d{1,2}.*\z/.match(time).to_s
      end

      def new_sched_row(day, opt, sched_row)
        open, close = hours(opt)
        {
            "service_id" => sched_row["service_id"],
            "weekday" => day,
            "opens_at" => open,
            "closes_at" => close,
            "original_text" => sched_row["original_text"]
        }
      end

      def remove_child_organizations
        @organizations.reject! do |org|
          org["parent_provider_id"] != ""
        end

        @organizations.each { |org| org.delete("parent_provider_id") }
      end
    end
  end
end