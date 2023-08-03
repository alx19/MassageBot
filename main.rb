require_relative 'config/setup'

Telegram::Bot::Client.run(CONFIG['token']) do |bot|
  bot.listen do |message|
    if message.from.id == CONFIG['master_id']
      Master.new(bot: bot, message: message).perform
    else
      Client.new(bot: bot, message: message).perform
    end
  end
rescue => e
  MyLogger.new.log_error(e)
  retry
end
