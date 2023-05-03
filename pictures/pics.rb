require 'telegram/bot'
require 'base64'
require 'faraday'
require 'faraday/multipart'
TOKEN = '5991437527:AAF7Fcr9eNQ6eykX6SVqrFvcVH7qC5_Q0rY'

10.times do |i|
  puts Telegram::Bot::Client.new(TOKEN).api.send_photo(chat_id: 173948014, photo: Faraday::UploadIO.new(File.expand_path("p#{i + 1}.jpg"), 'image/jpeg'))['result']['photo'].first['file_id']
end