require_relative 'mongo_client'
require_relative 'my_logger'
require 'telegram/bot'
TOKEN = ''

MongoClient.not_reminded.each do |rem|
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: rem['id'], text: "Напоминаем вам о записи на массаж #{rem['russian_datetime']}. Если планы поменялись, напишите @alicekoala, чтобы отменить запись.")
  MongoClient.set_reminded(rem['unix_timestamp'])
  MyLogger.new('log/succeded.txt').log("Напоминание о массаже #{rem['russian_datetime']} для #{rem['id']} успешно")
rescue => e
  MyLogger.new('log/failed_reminder.txt').log_error(e)
end
