require_relative 'config/setup'

Telegram::Bot::Client.run(TOKEN, logger: Logger.new($stderr)) do |bot|
  bot.listen do |message|
    MessageHandler.new(message: message, bot: bot).perform
  end
end
