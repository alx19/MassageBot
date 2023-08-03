class MessageParser
  def initialize(message)
    @message = message
    @text = message.text if @message.respond_to?(:text)
  end

  def parse
    if @text.match?(Regexp.new(RussianDate::MONTHS.join('|')))
      choose_date
    elsif @text.start_with?('Записать на')
      ask_for_create_appointment
    elsif @text.match?(/\d{2}\.\d{2}\.#{year}$/)
      choose_hour
    elsif @text.match?(/\d{2}\.\d{2}\.#{year} \d{1,2}$/)
      choose_minute
    elsif @text.match?(/^\d{2}\.\d{2}\.#{year} \d{1,2}:\d{1,2}$/)
      add_slot
    elsif @text == 'Показать расписание'
      show_slots
    elsif @text == 'Показать записи'
      show_appointments
    elsif @text == 'Добавить слот'
      choose_month
    elsif @text == 'Удалить слот'
      ask_for_remove_slot
    elsif @text == 'Разослать расписание'
      push_schedule
    elsif @text.match?('Удалить \d{1,2}')
      remove_slot
    elsif @text == 'Записать человечка'
      create_apointment
    elsif @text == 'Изменить слот'
      ask_for_change_slot
    elsif @text.match?('Изменить слот ')
      change_slot
    elsif MongoClient.get_switch
      add_apointment
    else
      show_options
    end
  end

  private

  def year
    @year ||= Time.now.year
  end
end