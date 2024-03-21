module Slot
  def add_slot
    date, time = @text.split
    MongoClient.add_slot(
      date: date, time: time,
      russian_datetime: RussianDate.to_russian(@text),
      unix_timestamp: Time.parse("#{date} #{time}").to_i,
      reminded: false
    )
    @bot.api.send_message(chat_id: MASTER_ID, text: "Слот на #{@text} создан.")
    show_options
  end

  def remove_slot
    if (slots = MongoClient.active_slots) != []
      kb = MongoClient.active_slots.map { |s| [Telegram::Bot::Types::KeyboardButton.new(text: "Удалить #{s['russian_datetime']}")] }
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
      data = { chat_id: MASTER_ID, text: 'Какой слот хотите удалить?', reply_markup: markup }
    else
      data = { chat_id: MASTER_ID, text: 'Нет слотов для удаления' }
    end
    @bot.api.send_message(**data)
    show_options if slots.empty?
  end

  def add_apointment
    kb = MongoClient.active_slots.map { |s| [Telegram::Bot::Types::KeyboardButton.new(text: "Записать на #{s['date']} #{s['time']}")] }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Выберите слот для записи?', reply_markup: markup)
  end

  def ask_for_new_time(slot)
    hours = (8..21).map(&:to_s)
    minutes = %w(00 15 30 45)
    kb = []
    hours.each do |hour|
      minutes.each do |minute|
        time = "#{hour}:#{minute}"
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(
          text: time,
          callback_data: "#{slot};#{time}"
        )
      end
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb.each_slice(5).to_a)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Выберите новое время', reply_markup: markup)
  end

  def clear_slot
    schedule = MongoClient.schedule
    if schedule.any?
      kb = []
      MongoClient.schedule.each do |slot|
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(
          text: slot['russian_datetime'],
          callback_data: "Удалить;#{slot['russian_datetime']}"
        )
      end
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb.each_slice(1).to_a)
      @bot.api.send_message(chat_id: MASTER_ID, text: 'Какую запись хотите удалить?', reply_markup: markup)
    else
      @bot.api.send_message(chat_id: MASTER_ID, text: 'Нет записей для удаления')
      show_options
    end
  end

  def ask_for_change
    kb = MongoClient.active_slots.map { |s| [Telegram::Bot::Types::KeyboardButton.new(text: "Изменить слот #{s['date']} #{s['time']}")] }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Какой слот хотите изменить?', reply_markup: markup)
  end

  def push_schedule
    text = [
      "На связи Алиса и у меня появились новые слоты!\n",
      'Можете ознакомиться с ними нажав опцию "Расписание и запись":'
    ]

    MongoClient.show_users.each do |user|
      next if user['id'] == MASTER_ID

      send_schedule(chat_id: user['id'], text: text.join("\n"), reply_markup: client_options_keyboard)
    end
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Уведомление о расписание разослано!')
    show_options
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
    kb = %w[00 15 30 45].map { |m| [Telegram::Bot::Types::KeyboardButton.new(text: "#{@text}:#{m}")] }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Выберите минуты', reply_markup: markup)
  end

  def send_schedule(**data)
    @bot.api.send_message(**data)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    return if e.error_code == '403'

    LOGGER.fatal('Caught exception;')
    LOGGER.fatal(e)
  end
end
