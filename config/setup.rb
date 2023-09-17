require 'telegram/bot'
require 'date'
require 'base64'
require 'faraday'
require 'faraday/multipart'
require 'dry-validation'
require 'ostruct'
require 'yaml'

# calendar
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'i18n'
require 'logger'

I18n.load_path << 'config/locales/datetime.ru.yml'
I18n.locale = :ru
I18n.reload!

LOGGER = Logger.new(ERRORS_LOG_PATH)

# Важно сначала инициализировать константы
require_relative 'config'

Dir[File.join(File.dirname(__FILE__), '../lib/', '**/*.rb')].each do |f|
  next if f.end_with?('master.rb') || f.end_with?('/client.rb')

  require_relative f
end

require_relative '../lib/master/master'
require_relative '../lib/client/client'
require_relative 'initialize_courses'
