require_relative 'mongo_client'
require_relative 'my_logger'
require 'telegram/bot'
TOKEN = ''

file = File.open('announcement.txt', 'r')
file_contents = file.read
file.close

MongoClient.show_users.each do |user|
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: user['id'], text: file_contents)
rescue => e
  MyLogger.new('log/failed_spam.txt').log_error(e)
end
