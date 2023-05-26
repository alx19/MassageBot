class Client
  include Path
  include Contraindications
  include Registration

  OPTIONS = %w[
    Посмотреть\ расписание\ и\ записаться Схема\ проезда
    Отменить\ запись Противопоказания
  ]

  def initialize(bot:, message:)
    @bot = bot
    @message = message
    @chat_id = message.from.id
    @info = info
  end

  def perform
    case @message.text
    when /Записаться на /
      russian_date = @message.text.sub('Записаться на ', '')
      slot = MongoClient.find_slot_by_russian_date(russian_date)
      if slot['state'] == 'reserved'
        send_message(chat_id: @chat_id, text: 'Извините, данный слот уже занят :(')
      else
        user = MongoClient.user_info(@chat_id)
        unix_timestamp = MongoClient.reserve_via_date_time(date: slot['date'], time: slot['time'], link: "<a href=\"tg://user?id=#{user['id']}\">#{user['name']}</a>", id: @chat_id)
        GoogleCalendar.add_event_to_calendar(unix_timestamp, "Массаж #{user['name']}", "t.me/#{user['username']}")
        send_message(chat_id: @chat_id, text: 'Спасибо за запись! За день до массажа мы на помним вам о нем. Ждем вас на массаж :)')
        send_message(chat_id: MASTER_ID, text: "<a href=\"tg://user?id=#{user['id']}\">#{user['name']}</a> записался на массаж #{russian_date}", parse_mode: 'HTML')
      end
      show_options
    when 'Посмотреть расписание и записаться'
      slots = MongoClient.active_slots
      if slots != []
        kb = slots.map { |s| [Telegram::Bot::Types::KeyboardButton.new(text: "Записаться на #{s['russian_datetime']}")] }
        kb << [Telegram::Bot::Types::KeyboardButton.new(text: 'Назад')]
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
        send_message(chat_id: @chat_id, text: 'Выберите слот для записи. На слоты до 17-00 действует скидка в 10%', reply_markup: markup)
      else
        send_message(chat_id: @chat_id, text: 'Свободных слотов нет :(')
      end
    when 'Схема проезда'
      send_path
      show_options
    when 'Противопоказания'
      send_contraindications
      show_options
    when 'Назад'
      show_options
    when 'Отменить запись'
      send_message(chat_id: @chat_id, text: 'Для отмены записи напишите мастеру @alicekoala')
      show_options
    when '/start'
      greetings
    else
      if not_registred?
        MongoClient.add_user(id: @chat_id, name: @message.text.strip, username: @message.from.username)
        send_message(chat_id: @chat_id, text: "Спасибо за регистрацию, #{@message.text.strip}")
      else
        send_message(chat_id: @chat_id, text: 'Нет такой команды, пожалуйста выберите из команд ниже')
      end
      show_options
    end
  end

  private

  def send_message(**data)
    begin
      @bot.api.send_message(**data)
    rescue => e
      MyLogger.new('messages_log.txt').log_error(e)
    end
  end

  def show_options
    kb = OPTIONS.map { |o| [Telegram::Bot::Types::KeyboardButton.new(text: o)] }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    send_message(chat_id: @chat_id, text: 'Что вы хотите сделать?', reply_markup: markup)
  end
end
