require_relative '../config/config'
require 'telegram/bot'

files = []
files.each do |file|
  puts "#{file} " + Telegram::Bot::Client.new(TOKEN).api.send_document(chat_id: ALEX_SPOON, document: Faraday::UploadIO.new(File.expand_path(file), 'pdf'))['result']['document']['file_id']
end
