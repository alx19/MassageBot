module Client
  module Options
    OPTIONS = %w[
      Расписание\ и\ запись Мои\ записи
      Стоимость\ и\ время Схема\ проезда
      Отменить\ запись Подарочный\ сертификат
      Противопоказания Курсы\ массажа
      Вопросы\ о\ массаже
    ].freeze

    def client_options_keyboard
      kb = OPTIONS.map { |o| Telegram::Bot::Types::KeyboardButton.new(text: o) }
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb.each_slice(2).to_a, one_time_keyboard: true)
    end
  end
end
