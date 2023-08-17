require_relative '../config/config'
require_relative '../lib/mongo_client'
require_relative '../lib/my_logger'

require 'telegram/bot'

file = File.open(File.join(__dir__, '..', 'bin', 'announcement.txt'), 'r')
file_contents = file.read
file.close

MongoClient.show_users.each do |user|
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: user['id'], text: file_contents)
rescue => e
  MyLogger.new('log/failed_spam.txt').log_error(e)
end
