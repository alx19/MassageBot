require 'i18n'
require 'date'

I18n.load_path << 'config/locales/datetime.ru.yml'
I18n.locale = :ru
I18n.reload!

require_relative '../russian_date'

describe RussianDate do
  describe '.to_russian' do
    it 'translate date correctly' do
      russian_date = RussianDate.to_russian('30.05.2023 15:30')
      expect(russian_date).to eq '30 мая(вторник) 15:30'
    end

    it 'raises error if date is incorrect' do
      expect { RussianDate.to_russian('33.05.2023 15:30') }.to raise_error Date::Error
    end
  end

  # describe '.days_of_month' do
  #   it 'shows correct amount of remain days' do
  #     days_count = RussianDate.days_of_month('Январь').size
  #     expect(days_count).to eq 31
  #   end
  # end
end