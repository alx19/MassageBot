# TODO: разослать расписание

class Master
  include Slot

  OPTIONS = %w[
    Добавить\ слот Показать\ расписание\ и\ записи
    Записать\ человечка Разослать\ расписание Изменить\ слот
    Удалить\ слот Удалить\ запись
  ].freeze

  def initialize(bot:, message:)
    @bot = bot
    @message = message
  end

  def perform
    case @message
    when Telegram::Bot::Types::CallbackQuery
      perform_callback
    when Telegram::Bot::Types::Message
      @text = @message.text.to_s
      perform_message
    end
  end

  def perform_callback
    if @message.data.start_with?('Удалить')
      _command, slot = @message.data.split(';')
      event_id = MongoClient.get_event_id({russian_datetime: slot})
      GoogleCalendar.delete_event(event_id)
      MongoClient.reset_slot(slot)
      @bot.api.send_message(chat_id: MASTER_ID, text: "Запись #{slot} удалена")
    else
      slot, time = @message.data.split(';')
      MongoClient.update_slot(slot, time)
      @bot.api.send_message(chat_id: MASTER_ID, text: 'Слот изменен')
    end
    show_options
  end

  def perform_message
    year = Time.now.year
    if @text.match?(Regexp.new(RussianDate::MONTHS.join('|')))
      choose_date
    elsif @text.start_with?('Записать на')
      date, time = @text.sub('Записать на ', '').split
      MongoClient.switch("#{date} #{time}")
      @bot.api.send_message(chat_id: MASTER_ID, text: 'Напишите описание для записи')
    elsif @text.match?(/\d{2}\.\d{2}\.#{year}$/)
      choose_hour
    elsif @text.match?(/\d{2}\.\d{2}\.#{year} \d{1,2}$/)
      choose_minute
    elsif @text.match?(/^\d{2}\.\d{2}\.#{year} \d{1,2}:\d{1,2}$/)
      add_slot
    elsif @text == 'Показать расписание и записи'
      active_slots = MongoClient.active_slots
      if active_slots.any?
        active_slots = active_slots.map do |s|
          username = s['username'] ? "@#{s['username']}" : nil
          [s['russian_datetime'], s['link'], username, s['text']].compact.join(' ')
        end.join("\n")
        @bot.api.send_message(chat_id: MASTER_ID, text: active_slots, parse_mode: 'HTML')
      else
        @bot.api.send_message(chat_id: MASTER_ID, text: 'Пока нет записей')
      end
      show_options
    elsif @text == 'Добавить слот'
      choose_month
    elsif @text == 'Удалить слот'
      remove_slot
    elsif @text == 'Удалить запись'
      clear_slot
    elsif @text == 'Разослать расписание'
      push_schedule
    elsif @text.match?('Удалить \d{1,2}')
      slot = @text.sub('Удалить ', '')
      begin
        MongoClient.remove_slot(slot)
        @bot.api.send_message(chat_id: MASTER_ID, text: "Слот #{slot} удален.")
        show_options
      rescue => e
        puts e.message
        @bot.api.send_message(chat_id: MASTER_ID, text: "Ошибка! Слот #{slot} не удален.")
      end
    elsif @text == 'Записать человечка'
      add_apointment
    elsif @text == 'Изменить слот'
      ask_for_change
    elsif @text.match?('Изменить слот ')
      slot = @text.sub('Изменить слот ', '')
      ask_for_new_time(slot)
    elsif MongoClient.get_switch
      date, time = MongoClient.switch.split
      unix_timestamp = MongoClient.reserve_via_date_time(date: date, time: time)
      result = GoogleCalendar.add_event_to_calendar(unix_timestamp, 'Массаж', @text)
      MongoClient.add_calendar_event_id({ unix_timestamp: unix_timestamp }, result.id, @text)
      @bot.api.send_message(chat_id: MASTER_ID, text: 'Запись создана')
      show_options
    else
      show_options
    end
  end

  private

  def show_options
    kb = OPTIONS.map { |option| Telegram::Bot::Types::KeyboardButton.new(text: option) }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb.each_slice(2).to_a, one_time_keyboard: true)
    @bot.api.send_message(chat_id: MASTER_ID, text: 'Что будете делать?', reply_markup: markup)
  end
end
