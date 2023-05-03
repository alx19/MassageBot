files = %w[
  ../calendar ../client/path ../client/contraindications ../client/registation
  ../client/client ../russian_date ../mongo_client
  ../master/slot ../master/master
]
files.each do |file|
  require_relative file
end

require 'telegram/bot'
require 'date'

# calendar
require 'google/apis/calendar_v3'
require 'googleauth'

require 'i18n'

I18n.load_path << 'config/locales/datetime.ru.yml'
I18n.locale = :ru
I18n.reload!

MASTER_ID = 149673513
