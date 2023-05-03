# TODO: разослать расписание

class Master
  include Slot

  OPTIONS = %w[
    Добавить\ слот Показать\ записи Показать\ расписание
    Записать\ человечка Разослать\ расписание Удалить\ слот
  ].freeze

  def initialize(bot:, message:)
    @bot = bot
    @message = message
    @text = message.text
  end

  def perform
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
    elsif @text.match?(/\d{2}\.\d{2}\.#{year} \d{1,2}:\d{1,2}$/)
      add_slot
    elsif @text == 'Показать расписание'
      active_slots = MongoClient.active_slots
      if active_slots.any?
        active_slots = active_slots.map { |s| s['russian_datetime'] }.join("\n")
        @bot.api.send_message(chat_id: MASTER_ID, text: active_slots)
      else
        @bot.api.send_message(chat_id: MASTER_ID, text: 'Пока нет записей')
      end
      show_options
    elsif @text == 'Показать записи'
      if (schedule = MongoClient.schedule) != []
        text = schedule.map do |s|
          "#{s['russian_datetime']} #{s['link']}"
        end.join("\n")
      else
        text = 'Никто не записан :('
      end
      @bot.api.send_message(chat_id: MASTER_ID, text: text, parse_mode: 'HTML')
    elsif @text == 'Добавить слот'
      choose_month
    elsif @text == 'Удалить слот'
      remove_slot
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
    elsif MongoClient.get_switch
      date, time = MongoClient.switch.split
      timestamp = MongoClient.reserve_via_date_time(date: date, time: time)
      Calendar.add_event_to_calendar(timestamp, 'Массаж', @text)
      @bot.api.send_message(chat_id: MASTER_ID, text: 'Запись создана')
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

__END__
add_event_to_calendar(@message.data.to_i, 'Первый массаж!')
@bot.api.send_message(chat_id: MASTER_ID, text: 'Запись создана')