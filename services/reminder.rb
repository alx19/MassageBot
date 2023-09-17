require_relative '../config/config'
require_relative '../lib/mongo_client'

require 'telegram/bot'

LOGGER = Logger.new(OTHER_LOG_PATH)

MongoClient.not_reminded.each do |rem|
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: rem['id'], text: "Напоминаем вам о записи на массаж #{rem['russian_datetime']}. Если планы поменялись, напишите @alicekoala, чтобы отменить запись.")
  MongoClient.set_reminded(rem['unix_timestamp'])
  LOGGER.info("Напоминание о массаже #{rem['russian_datetime']} для #{rem['id']} успешно")
rescue => e
  LOGGER.fatal('Caught exception:')
  LOGGER.fatal(e)
end

LOGGER.close
