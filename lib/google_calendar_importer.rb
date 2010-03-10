module GoogleCalendarImporter
  class Calendar

    # should take the form of:
    #
    #  calendar = GoogleCalendarImporter::Calendar.new("http://www.google.com/calendar/feeds/studiodanger@gmail.com/private-1234567890ABCDEFG/full")
    #  calendar.events.each do |event|
    #    Event.new(:id => event.id, :name => event.name)
    #    User.new :email => event.who
    #    # etc.
    #  end
    #
    attr_accessor :uri

    def initialize(uri)
      require 'net/http'
      @uri = URI.parse(uri)
    end

    def events
      gem 'hpricot'
      require 'hpricot'
      (Hpricot.parse(xml)/'entry').map do |event|
        GoogleCalendarImporter::Extensible.new(event)
      end
    end

    protected

      def xml
        @xml ||= perform
      end

      def perform
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.get(uri.path).body
        end
      end
  end

  class Extensible
    @@map = {
      :uri          => 'id',
      :recurrence   => 'gd:recurrence',
      :created_at   => 'published',
      :updated_at   => 'updated',
      :name         => 'title',
      :description  => 'content'
    }

    attr_accessor :obj

    delegate :inspect, :to => :obj

    def initialize(obj)
      @obj = obj
    end

    def [](name)
      respond_to?(name) ?
        self[name] :
        (obj / @@map[name.to_sym] || name).inner_text
    end

    def where
      first_attribute 'gd:where', 'valueString'
    end

    def email
      first_attribute 'gd:who', 'email'
    end
    alias who email

    def id
      first_attribute 'gcal:uid', 'value'
    end

    def version
      first_attribute 'gcal:sequence', 'valueString'
    end

    protected
      def first_attribute(search, attribute)
        collection = Array(obj / search).flatten
        collection.first.attributes[attribute] if collection.length > 0
      end

      def method_missing(method, *args, &block)
        self[method]
      end
  end
end

