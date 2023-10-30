require_relative '../config/config'
require_relative '../lib/mongo_client'

require 'telegram/bot'
require 'csv'
require 'date'

csv_file = "stats#{Date.today}.csv"

# Запись данных в CSV
CSV.open(csv_file, 'wb') do |csv|
  # Записываем шапку
  csv << %w[id name username massages]

  # Итерируемся по массиву хешей и записываем данные
  MongoClient.show_users.each do |hash|
    csv << [hash[:id], hash[:name], hash[:username], MongoClient.count_slots_by_id(hash[:id])]
  end
end

Telegram::Bot::Client.new(TOKEN).api.send_document(chat_id: MASTER_ID, document: Faraday::UploadIO.new(csv_file, 'text/csv'))
