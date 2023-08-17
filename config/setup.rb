require 'dotenv/load'
require 'telegram/bot'
require 'date'
require 'base64'
require 'faraday'
require 'faraday/multipart'
require 'dry-validation'
require 'ostruct'

# calendar
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'i18n'

I18n.load_path << 'config/locales/datetime.ru.yml'
I18n.locale = :ru
I18n.reload!

Dir[File.join(File.dirname(__FILE__), '../lib/', '**/*.rb')].each do |f|
  next if f.end_with?('master.rb') || f.end_with?('/client.rb')

  require_relative f 
end

require_relative '../lib/master/master.rb'
require_relative '../lib/client/client.rb'
require_relative 'initialize_courses.rb'
