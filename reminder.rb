require_relative 'mongo_client'
TOKEN = ''

MongoClient.not_reminded.each do |rem|
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: rem['id'], text: "Напоминаем вам о записи на массаж #{rem['russian_datetime']}")
  set_reminded(rem['unix_timestamp'])
end