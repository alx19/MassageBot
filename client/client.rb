class Client
  include Path
  include Contraindications
  include Registration

  OPTIONS = %w[
    Расписание\ и\ запись Мои\ записи
    Стоимость\ и\ время Схема\ проезда
    Отменить\ запись Подарочный\ сертификат
    Противопоказания
  ]

  def initialize(bot:, message:)
    @bot = bot
    @message = message
    @chat_id = message.from.id
    @info = info
  end

  def perform
    return unless @message.is_a? Telegram::Bot::Types::Message

    case @message.text
    when /Записаться на /
      russian_date = @message.text.sub('Записаться на ', '')
      slot = MongoClient.find_slot_by_russian_date(russian_date)
      return no_slot unless slot

      if slot['state'] == 'reserved'
        send_message(chat_id: @chat_id, text: 'Извините, данный слот уже занят :(')
      else
        user = MongoClient.user_info(@chat_id)
        unix_timestamp = MongoClient.reserve_via_date_time(
          date: slot['date'],
          time: slot['time'],
          link: "<a href=\"tg://user?id=#{user['id']}\">#{user['name']}</a>",
          username: @message.from.username,
          id: @chat_id
        )
        result = GoogleCalendar.add_event_to_calendar(unix_timestamp, "Массаж #{user['name']}", "t.me/#{user['username']}")
        MongoClient.add_calendar_event_id({ unix_timestamp: unix_timestamp }, result.id)
        send_message(chat_id: @chat_id, text: 'Спасибо за запись, @alicekoala будет ждать вас на массаж. За день до массажа напомню вам о нем')
        send_message(chat_id: MASTER_ID, text: "<a href=\"tg://user?id=#{user['id']}\">#{user['name']}</a> записался на массаж #{russian_date}", parse_mode: 'HTML')
      end
      show_options
    when 'Расписание и запись'
      slots = MongoClient.active_slots
      if slots != []
        kb = slots.map { |s| [Telegram::Bot::Types::KeyboardButton.new(text: "Записаться на #{s['russian_datetime']}")] }
        kb << [Telegram::Bot::Types::KeyboardButton.new(text: 'Назад')]
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
        send_message(chat_id: @chat_id, text: 'Выберите слот для записи. На слоты до 16-00 действует скидка в 10%', reply_markup: markup)
      else
        send_message_and_options('Свободных слотов нет :(')
      end
    when 'Схема проезда'
      send_path
      show_options
    when 'Противопоказания'
      send_contraindications
      show_options
    when 'Мои записи'
      show_my_appointments
      show_options
    when 'Назад'
      show_options
    when 'Стоимость и время'
      send_message_and_options(about_cost_and_time)
    when 'Отменить запись'
      send_message_and_options('Для отмены записи напишите мастеру @alicekoala')
    when 'Подарочный сертификат'
      send_message_and_options(about_sertificate)
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

  def about_sertificate
    [
      "На массаж можно не только прийти, но и подарить его другому человеку.",
      "После оплаты вы получите электронный сертификат, который можно отправить одариваемому человеку.",
      "",
      "Срок действия — 12 месяцев в с даты покупки.",
      "Чтобы купить его — напишите @alicekoala 🐨"
    ].join("\n")
  end

  def about_cost_and_time
    ["<b>Стоимость</b>", about_cost, "", "<b>Время</b>", about_time].join("\n")
  end

  def about_cost
    text = [
      "3000р за час массажа, 90 минут и 120 минут стоят 4500 рублей и 6000 соответственно\n",
      "В это время не включено прийти, раздеться, поговорить после и выпить чаю.",
      "Стандартный сеанс, который включает в себя массаж всего человека, длится полтора часа, именно его я советую для первого раза.\n",
      "Сейчас на дневные сеансы, которые начинаются до 16:00 действует скидка 10%, час будет стоить 2700р, полтора — 4000."
    ].join("\n")
  end

  def about_time
    text = [
      "Можно прийти на 5-7 минут раньше, сильно заранее не нужно.\n",
      "К времени самого массажа можно добавлять 30 минут, то есть если вы записались на часовой массаж, весь визит займет около полутора часов\n",
      "Если вы опаздываете более, чем на 10 минут — сеанс будет короче, чтобы не пострадало расписание и другие клиенты"
    ].join("\n")
  end

  def send_message_and_options(text)
    send_message(chat_id: @chat_id, text: text, parse_mode: 'HTML')
    show_options
  end

  def no_slot
    send_message(chat_id: @chat_id, text: 'Данный слот был удален, извините')
    show_options
  end

  def send_message(**data)
    begin
      @bot.api.send_message(**data)
    rescue => e
      MyLogger.new('messages_log.txt').log_error(e)
    end
  end

  def show_options
    kb = OPTIONS.map { |o| Telegram::Bot::Types::KeyboardButton.new(text: o) }
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb.each_slice(2).to_a, one_time_keyboard: true)
    send_message(chat_id: @chat_id, text: 'Что вы хотите сделать?', reply_markup: markup)
  end

  def show_my_appointments
    appointments = MongoClient.show_users_appointments(@chat_id)
    if appointments != []
      text = appointments.map do |s|
        "#{s['russian_datetime']}"
      end.join("\n")
    else
      text = 'У вас нет записей :('
    end
    @bot.api.send_message(chat_id: @chat_id, text: text)
  end
end
