require_relative 'config/setup'

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    if message.from.id == MASTER_ID
      Master.new(bot: bot, message: message).perform
    else
      Client.new(bot: bot, message: message).perform
    end
  end
rescue => e
  MyLogger.new.log(e)
  retry
end
