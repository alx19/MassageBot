module Slot
  def add_slot
    date, time = @text.split
    MongoClient.add_slot(
      date: date, time: time,
      russian_datetime: RussianDate.to_russian(@text),
      unix_timestamp: Time.parse("#{date} #{time}").to_i,
      pushed: false,
      reminded: false
    )
    @bot.api.send_message(chat_id: MASTER_ID, text: "Слот на #{@text} создан.")
    show_options
  end

  def remove_slot
    kb = MongoClient.active_slots.map { |s| [Telegram::Bot::Types::KeyboardButton.new(text: "Удалить #{s['russian_datetime']}")] }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Какой слот хотите удалить?', reply_markup: markup)
  end

  def add_apointment
    kb = MongoClient.active_slots.map { |s| [Telegram::Bot::Types::KeyboardButton.new(text: "Записать на #{s['date']} #{s['time']}")] }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Выберите слот для записи?', reply_markup: markup)
  end

  def push_schedule
    text = ['На связи Алиса и у меня появились новые слоты!', '']
    MongoClient.not_pushed.each { |np| text << np['russian_datetime'] }
    MongoClient.show_users.each do |user|
      @bot.api.send_message(chat_id: user['id'], text: text.join("\n"))
    end
    MongoClient.set_pushed
  end

  private

  def choose_month
    kb = RussianDate.current_and_next_month.map { |m| [Telegram::Bot::Types::KeyboardButton.new(text: m)] }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Выберите месяц', reply_markup: markup)
  end

  def choose_date
    kb = RussianDate.days_of_month(@text).map { |d| Telegram::Bot::Types::KeyboardButton.new(text: d) }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb.each_slice(3).to_a, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Выберите дату', reply_markup: markup)
  end

  def choose_hour
    kb = (8..21).map { |h| Telegram::Bot::Types::KeyboardButton.new(text: "#{@text} #{h}") }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb.each_slice(3).to_a, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Выберите час', reply_markup: markup)
  end

  def choose_minute
    kb = %w[00 30].map { |m| [Telegram::Bot::Types::KeyboardButton.new(text: "#{@text}:#{m}")] }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Выберите минуты', reply_markup: markup)
  end
end