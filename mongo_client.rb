require 'mongo'

MONGO = Mongo::Client.new('')

class MongoClient
  class << self
    def reserve_via_date_time(date:, time:, link: '', id: '')
      MONGO['slots'].update_one(
        { date: date, time: time },
        { '$set' => { state: 'reserved', link: link, id: id } }
      )
      MONGO['slots'].find(date: date, time: time).to_a.first['unix_timestamp']
    end

    def schedule
      MONGO['slots'].find(
        {
          'state' => 'reserved',
          'unix_timestamp' => { '$gt' => Time.now.utc.to_i }
        }
      ).to_a
    end

    def show_users
      MONGO['users'].find.to_a
    end

    def find_slot_by_russian_date(russian_datetime)
      MONGO['slots'].find(russian_datetime: russian_datetime).to_a.first
    end

    def add_user(data) # id, name, username
      MONGO['users'].insert_one(created_at: Time.now.to_f, **data)
    end

    def update_user(id, data)
      MONGO['users'].update_one({ id: id }, { '$set' => data })
    end

    def user_info(id)
      MONGO['users'].find(id: id).to_a.first
    end

    def add_slot(data)
      MONGO['slots'].update_one(
        { unix_timestamp: data[:unix_timestamp] },
        { '$set' => data.merge({ state: 'active' }) },
        upsert: true
      )
    end

    def active_slots
      MONGO['slots'].find(
        {
          state: 'active',
          unix_timestamp: { '$gt' => Time.now.utc.to_i }
        }
      ).to_a
    end

    def not_pushed
      MONGO['slots'].find(
        {
          state: 'active',
          unix_timestamp: { '$gt' => Time.now.utc.to_i },
          pushed: false
        }
      ).to_a
    end

    def not_reminded
      MONGO['slots'].find(
        {
          state: 'active',
          reminded: false,
          id: { '$ne' => '' },
          unix_timestamp: { '$lt' => Time.now.utc.to_i + 86520}
        }
      ).to_a
    end

    def set_reminded(unix_timestamp)
      MONGO['slots'].update_one(
        {
          unix_timestamp: unix_timestamp
        },
        { '$set' => { reminded: true } }
      )
    end

    def set_pushed
      MONGO['slots'].update_many({ pushed: false }, { '$set' => { pushed: true } })
    end

    def remove_slot(dt)
      MONGO['slots'].delete_one(russian_datetime: dt)
    end

    def switch(timestamp = nil)
      state = get_switch
      if timestamp
        MONGO['switch'].update_one(
          { state: state },
          { '$set' => { state: !state, timestamp: timestamp } },
          upsert: true
        )
      else
        MONGO['switch'].update_one(
          { state: state },
          { '$set' => { state: !state } },
          upsert: true
        )
        MONGO['switch'].find.to_a.first['timestamp']
      end
    end

    def get_switch
      (MONGO['switch'].find.to_a.first || Hash.new(false))['state']
    end
  end
end