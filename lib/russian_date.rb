class RussianDate
  MONTHS = %w(Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь).freeze

  class << self
    def days_of_month(month)
      today = Date.today
      m = MONTHS.index(month) + 1
      y = month == 'Январь' && today.month == 12 ? today.year + 1 : today.year
      start = m == today.month ? today.day : 1
      (Date.new(y, m, start)..Date.new(y, m, -1)).map do |dt|
        dt.strftime('%d.%m.%Y')
      end
    end

    def to_russian(datetime)
      I18n.l(DateTime.parse(datetime), format: :special).strip
    end

    def current_and_next_month
      current_month = Date.today.month
      [current_month - 1, current_month % 12].map do |month_number|
        MONTHS[month_number]
      end
    end
  end
end
