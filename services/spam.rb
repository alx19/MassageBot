require_relative '../config/config'
require_relative '../lib/mongo_client'

require 'telegram/bot'

file = File.open(File.join(__dir__, '..', 'bin', 'announcement.txt'), 'r')
file_contents = file.read
file.close

LOGGER = Logger.new(OTHER_LOG_PATH)

MongoClient.show_users.each do |user|
  Telegram::Bot::Client.new(TOKEN).api.send_message(chat_id: user['id'], text: file_contents)
rescue => e
  LOGGER.fatal('Caught exception; exiting')
  LOGGER.fatal(e)
end

LOGGER.close
