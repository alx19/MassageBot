class Calendar
  class << self
    def add_event_to_calendar(timestamp, event_name, note = '')
      # Setup the Calendar API
      calendar = Google::Apis::CalendarV3::CalendarService.new
      googleauth(calendar)

      # Set up the event parameters
      event = Google::Apis::CalendarV3::Event.new(
        summary: event_name,
        description: note,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: Time.at(timestamp).iso8601,
          time_zone: 'UTC'
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: Time.at(timestamp + 7200).iso8601,
          time_zone: 'UTC'
        ),
        reminders: Google::Apis::CalendarV3::Event::Reminders.new(
          use_default: false,
          overrides: []
        )
      )

      # Insert the event into the calendar
      calendar.insert_event('lfrdj8p2s6jcmrvs31r0vhbkic@group.calendar.google.com', event)
    end

    private

    def googleauth(calendar)
      calendar.client_options.application_name = 'Ruby Google Calendar API'
      calendar.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open('config/cred.json'),
        scope: Google::Apis::CalendarV3::AUTH_CALENDAR
      )
    end
  end
end
