require_relative 'config/setup'

file = File.open(MAIN_LOG_PATH, 'a')
logger = Logger.new(file)

Telegram::Bot::Client.run(TOKEN, logger: Logger.new(logger)) do |bot|
  bot.listen do |message|
    MessageHandler.new(message: message, bot: bot).perform
  end
end
