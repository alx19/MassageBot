require_relative '../config/config'
require_relative '../lib/mongo_client'

require 'telegram/bot'

LOGGER = Logger.new(OTHER_LOG_PATH)

string = """Напоминаем вам о записи на массаж %{datetime}s. Если планы поменялись, напишите @alicekoala, чтобы отменить запись.\n
Вам также могут быть полезны следующие команды:
/location - Схема проезда
/contraindications - Противопоказания"""

MongoClient.not_reminded.each do |rem|
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: rem['id'], text: string % {datetime: rem['russian_datetime']})
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: rem['id'], text: '🚘Также сообщаем вам, что мы переехали, подробнее по команде /location')
  MongoClient.set_reminded(rem['unix_timestamp'])
  LOGGER.info("Напоминание о массаже #{rem['russian_datetime']} для #{rem['id']} успешно")
rescue => e
  LOGGER.fatal('Caught exception:')
  LOGGER.fatal(e)
  LOGGER.fatal("User ID: #{rem['id']} banned our bot!")
end

LOGGER.close
