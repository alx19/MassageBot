class StateMachine
  STATES = Hash.new(Hash.new)

  def initialize(id)
    @state = fetch_state(id)
  end

  def next
    STATES[@state]['next']
  end

  def prev
    STATES[@state]['prev']
  end

  private

  def fetch_state
    MongoClient.fetch_state(id)['name'] || 'initial'
  end
end