module Client
  module Path
    # Telegram file_id's for pictures
    PICTURES = [
      'AgACAgIAAxkDAAJ__mazSyqH-jAjTxTGWkR3PrXRScYCAAI13zEb3rSgSU0l9RG9Zd5MAQADAgADeQADNQQ',
      'AgACAgIAAxkDAAJ__2azSyt07OYzZIL7oMA6zaGQucNxAAI23zEb3rSgSeHX__ttdqVMAQADAgADeQADNQQ'
    ].freeze
    CAPTION = [
      "Адрес: 1-ый Смоленский пер. 24А, 3 подъезд. На домофоне 110, копка лифта 10. После лифта — три пролета наверх (как будто 11 этаж)\n",
      '3 минуты от м. Смоленская(голубая, Филевская ветка🩵)',
      '5 минут от м. Смоленская(синяя, Арбатско-Покровская ветка💙)'
    ].freeze

    def send_path
      photos = []
      PICTURES.each_with_index do |file_id, index|
        caption = index.zero? ? CAPTION.join("\n") : ''
        photos << Telegram::Bot::Types::InputMediaPhoto.new(media: file_id, caption: caption)
      end
      @bot.api.send_media_group(chat_id: @chat_id, media: photos)
    end
  end
end
