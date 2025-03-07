module Client
  class Client
    include Path
    include Contraindications
    include Registration
    include Options
    #include Payment::Course
    include Faq

    def initialize(bot:, message:)
      @bot = bot
      @message = message
      @chat_id = message.from.id
      @info = info
    end

    def perform
      return send_course_and_invoice if @message.is_a? Telegram::Bot::Types::CallbackQuery
      return unless @message.is_a? Telegram::Bot::Types::Message

      case @message.text
      when /Записаться на /
        russian_date = @message.text.sub('Записаться на ', '')
        slot = MongoClient.find_slot_by_russian_date(russian_date)
        return no_slot unless slot

        if slot['state'] == 'reserved'
          send_message(chat_id: @chat_id, text: 'Извините, данный слот уже занят :(')
        elsif Time.now.utc.to_i > slot['unix_timestamp']
          send_message(chat_id: @chat_id, text: 'Извините, время записи на этот слот уже вышло')
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
          username = @message.from.username ? '' : "@#{@message.from.username} "
          MongoClient.add_calendar_event_id({ unix_timestamp: unix_timestamp }, result.id) if result
          send_message(chat_id: @chat_id, text: 'Спасибо за запись, @alicekoala будет ждать вас на массаж. За день до массажа напомню вам о нем')
          send_message(chat_id: @chat_id, text: '🚘Также сообщаем вам, что мы переехали, подробнее по команде /location')
          send_message(chat_id: MASTER_ID, text: "<a href=\"tg://user?id=#{user['id']}\">#{user['name']}</a> #{username}записался на массаж #{russian_date}", parse_mode: 'HTML')
        end
        show_options
      when 'Расписание и запись', '/schedule'
        #send_message(chat_id: @chat_id, text: 'Алиса уехала из Москвы до начала марта. А как получить хороший массаж в её отсутствие, рассказала <a href="https://t.me/timetojmakjmak/273">тут</a>', parse_mode: 'HTML')
        send_schedule
        send_message(chat_id: @chat_id, text: '🚘Также сообщаем вам, что мы переехали, подробнее по команде /location')
      when 'Схема проезда', '/location'
        send_path
        show_options
      when 'Противопоказания', '/contraindications'
        send_contraindications
        show_options
      when 'Мои записи', '/appointments'
        show_my_appointments
        show_options
      when 'Назад'
        show_options
      when 'Стоимость и время', '/costtime'
        send_message_and_options(about_cost_and_time)
      when 'Отменить запись', '/cancel'
        send_message_and_options('Для отмены записи напишите мастеру @alicekoala')
      when 'Подарочный сертификат', '/certificate'
        send_message_and_options(about_sertificate)
      when 'Курсы массажа', '/courses'
        send_courses
      when 'Вопросы о массаже', '/faq'
        send_faq
        show_options
      when '/start'
        not_registred? ? greetings : show_options
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
      [
        "3600р  за час массажа",
        "75 минут — 4500",
        "90 минут — 5400",
        "2 часа — 6500",
        "3 часа — 9000, для длинных сеансов я делаю цену ниже, потому что мне они очень нравятся.\n",
        "В это время не включено прийти, раздеться, поговорить после и выпить чаю.",
        "Стандартный сеанс, который включает в себя массаж всего человека, длится полтора часа, именно его я советую для первого раза.\n",
        "Есть абонемент, 6 часов массажа стоят 19 000 вместо 21 600. Его можно разбить на сеансы по часу/полтора или два.",
        "Абонемент действует 6 месяцев начиная с первого сеанса.\n",
        "Скидки:",
        "1. Для богинь, которые сделали нового человека(и ему меньше трех лет) — 90 минут массажа за 4000, по коду Я мама",
        "2. Если вы покупаете любой подарочный сертификат, у вас будет скидка 10% на ваш следующий сеанс массажа",
        "3. Если по вашей рекомендации пришел друг, он\а получает скидку 10% на свой первый сеанс, и вы тоже получаете 10%"
      ].join("\n")
    end

    def about_time
      [
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
      @bot.api.send_message(**data)
    rescue Telegram::Bot::Exceptions::ResponseError => e
      return if e.error_code == '403'

      LOGGER.fatal('Caught exception;')
      LOGGER.fatal(e)
    end

    def show_options
      send_message(chat_id: @chat_id, text: 'Что вы хотите сделать?', reply_markup: client_options_keyboard)
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

    def send_courses
      kb = []
      COURSES.each_with_index do |course, index|
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(
          text: course.title,
          callback_data: "course_#{index}"
        )
      end
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb.each_slice(1).to_a)
      @bot.api.send_message(chat_id: @chat_id, text: 'Выберите курс:', reply_markup: markup)
    end

    def send_course_and_invoice
      course_id = @message.data.match(/\d+/)[0].to_i
      ::Client::Payments::Course.new(bot: @bot, chat_id: @chat_id, course_id: course_id).sell_course
    end

    def send_schedule
      return send_vacation if ENV['VACATION_DATE']

      slots = MongoClient.active_slots
      if slots != []
        kb = slots.map { |s| [Telegram::Bot::Types::KeyboardButton.new(text: "Записаться на #{s['russian_datetime']}")] }
        kb << [Telegram::Bot::Types::KeyboardButton.new(text: 'Назад')]
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
        send_message(chat_id: @chat_id, text: 'Выберите слот для записи:', reply_markup: markup)
      else
        send_message_and_options('Свободных слотов нет :(')
      end
    end

    def send_vacation
      text = "До #{ENV['VACATION_DATE']} записаться нельзя, @alicekoala в отпуске. Пока можно купить уроки по массажу дома. Как только появятся новые слоты — вы узнаете о них из рассылки."
      send_message_and_options(text)
    end
  end
end
