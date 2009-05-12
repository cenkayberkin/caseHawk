module RiCal
  module CoreExtensions #:nodoc:
    module Date #:nodoc:
      #- ©2009 Rick DeNatale
      #- All rights reserved. Refer to the file README.txt for the license
      #
      module Conversions
        # Return an RiCal::PropertyValue::DateTime representing the receiver
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::DateTime.new(nil, :value => self)
        end
        
        # Return an RiCal::PropertyValue::Date representing the receiver
        def to_ri_cal_date_value
          RiCal::PropertyValue::Date.new(nil, :value => self)
        end

        alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_value
        
        # Return the natural ri_cal_property for this object
        def to_ri_cal_property_value
          to_ri_cal_date_value
        end
      end
    end
  end
end