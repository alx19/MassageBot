module Client
  module Path
    # Telegram file_id's for pictures
    PICTURES = [
      [
        'AgACAgIAAxkDAAMhZFHybJDML5JfogtgdCshj8ssTNUAAirGMRuAO5BKTjREjGpfnmEBAAMCAANzAAMvBA',
        'AgACAgIAAxkDAAMiZFHybdVFCtxoqgPumfZPVFJDKqkAAivGMRuAO5BK_MjjEu-1wh0BAAMCAANzAAMvBA',
        'AgACAgIAAxkDAAMjZFHybjjaB0_wSc2HPWTkbhYR_J4AAizGMRuAO5BKaVJ8HDp5G7sBAAMCAANzAAMvBA',
        'AgACAgIAAxkDAAMkZFHyb8bAg72DMfNaMeOmmskYgHYAAi3GMRuAO5BKhCpQDtSDbbYBAAMCAANzAAMvBA'
      ],
      [
        'AgACAgIAAxkDAAMlZFHyb1pBhTdQjgvHnXerz-zOjkQAAi7GMRuAO5BKMZdAIrLhyHoBAAMCAANzAAMvBA',
        'AgACAgIAAxkDAAMmZFHycbGC6yQjLfGVnPGtg7HfxWcAAi_GMRuAO5BK8_1mwrkatnMBAAMCAANzAAMvBA',
        'AgACAgIAAxkDAAMnZFHycSco61cFAp3t-yuLf7os6acAAjDGMRuAO5BKeeELZk0wTZUBAAMCAANzAAMvBA',
        'AgACAgIAAxkDAAMoZFHydjML3-5e2M91NY_0VwABlJIdAAIxxjEbgDuQSm53Fa5hsLbHAQADAgADcwADLwQ'
      ],
      [
        'AgACAgIAAxkDAAMpZFHyd7URWtx9zQ-DIUZkS0XstIQAAjLGMRuAO5BKDfbxtPOxz_0BAAMCAANzAAMvBA',
        'AgACAgIAAxkDAAMqZFHydwvlB36FK9q_6v7TtwjwCg8AAjPGMRuAO5BKUj2uMRiJDUQBAAMCAANzAAMvBA'
      ]
    ]
    CAPTION = [
      "Адрес: Старосадский переулок, 5/8с5\n\nМетро Китай город, 6 выход, из метро направо и по Маросейке до магазина Магнолия, перед ним повернуть направо",
      'Дальше следуйте по стрелочкам',
      'На двери кнопка 2'
    ]

    def send_path
      3.times do |message|
        photos = []
        PICTURES[message].each_with_index do |file_id, index|
          caption = index.zero? ? CAPTION[message] : ''
          photos << Telegram::Bot::Types::InputMediaPhoto.new(media: file_id, caption: caption)
        end
        @bot.api.send_media_group(chat_id: @chat_id, media: photos)
        sleep(0.5)
      end
    end
  end
end
