module Path
  # Telegram file_id's for pictures
  PICTURES = [
    [
      'AgACAgIAAxkDAAICBWRO2DvcJINqTOxykE7YS636nOzEAAIIzDEbS9hwShlE-Tecekr2AQADAgADcwADLwQ',
      'AgACAgIAAxkDAAICB2RO2KDXq6dROayW1R-dqE_p3jR3AAILzDEbS9hwSnCNniNdrigmAQADAgADcwADLwQ',
      'AgACAgIAAxkDAAICCGRO2KHttrTIj2NKw2oO1ZAcX7j5AAIMzDEbS9hwSvHhjSrNgZvRAQADAgADcwADLwQ',
      'AgACAgIAAxkDAAICCWRO2KJ67h09qb4PtYc3p6otl9jmAAINzDEbS9hwSq_teaNyDgUFAQADAgADcwADLwQ'
    ],
    [
      'AgACAgIAAxkDAAICCmRO2KJZ_YGTF-Qr5HnXXNBJLEYnAAIOzDEbS9hwSkjlIjFds01CAQADAgADcwADLwQ',
      'AgACAgIAAxkDAAICC2RO2KOUjg1H94jFfuEpt3FqzWQEAAIPzDEbS9hwSpdYpthYMva_AQADAgADcwADLwQ',
      'AgACAgIAAxkDAAICDGRO2KSe-BI3HyXiklxtyvpLForcAAIQzDEbS9hwSrG9oG_-Ou1iAQADAgADcwADLwQ',
      'AgACAgIAAxkDAAICDWRO2KZxmiYX2JHoUWFmBA2G26OrAAIRzDEbS9hwSkb8XgFGCL4dAQADAgADcwADLwQ'
    ],
    [
      'AgACAgIAAxkDAAICDmRO2KbetaeI_eaiKvp9YEQScxiiAAISzDEbS9hwSuuo1o_6RztCAQADAgADcwADLwQ',
      'AgACAgIAAxkDAAICD2RO2KdeTdzQxwxTS6E9ir72bGWGAAITzDEbS9hwSib4Cxh8JjltAQADAgADcwADLwQ'
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
