module RiCal
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      #- ©2009 Rick DeNatale
      #- All rights reserved. Refer to the file README.txt for the license
      #
      module Conversions
        # Parse the receiver as an RiCal::PropertyValue::DateTime
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::DateTime.from_string(self)
        end

        alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_time_value

        # Parse the receiver as an RiCal::PropertyValue::DurationValue
        def to_ri_cal_duration_value
          RiCal::PropertyValue::Duration.from_string(self)
        end

        # code stolen from ActiveSupport Gem
        unless  ::String.instance_methods.include?("camelize")
          # Convert the receiver to camelized form
          # This method duplicates the method provided by ActiveSupport, and will only be defined
          # by the RiCal gem if it is not already defined.
          def camelize
            self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
          end
        end
      end
    end
  end
end