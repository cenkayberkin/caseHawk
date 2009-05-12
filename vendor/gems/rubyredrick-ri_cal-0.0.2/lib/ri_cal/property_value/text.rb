module RiCal
  class PropertyValue
    #- ©2009 Rick DeNatale
    #- All rights reserved. Refer to the file README.txt for the license
    #
    # RiCal::PropertyValue::Text represents an icalendar Text property value
    # which is defined in 
    # rfc 2445 section 4.3.11 pp 45-46
    class Text < PropertyValue
      
      # Return the string value of the receiver
      def ruby_value
        if value
          value.gsub(/\\[;,nN\\]/) {|match|
            case match[1,1]
            when /[,;\\]/
              match[1,1]
            when 'n', 'N'
              "\n"
            else
              match
            end
          }
        else
          nil
        end
      end
      
      def self.convert(parent, string) #:nodoc:
        ical_str = string.gsub(/\n|,|;/) {|match|
          if match == "\n"
            '\n'
          else
            "\\#{match}"
          end
          }
        self.new(parent, :value => ical_str)
      end
    end
  end
end