require_relative 'config/setup'

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    MessageHandler.new(message: message, bot: bot).perform
  end
rescue => e
  MyLogger.new.log(e)
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: ALEX_SPOON, text: "Бот Алисы упал!")
end
