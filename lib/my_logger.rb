class MyLogger
  def initialize(file = 'log.txt')
    @file = File.join(__dir__, '..', 'log', file)
  end

  def log_error(error, message_text = '')
    File.open(@file, 'a') { |f| f.write "#{Time.now}: #{error} #{error.full_message}, message_text: #{message_text}\n" }
  end

  def log(text)
    File.open(@file, 'a') { |f| f.write "#{Time.now}: #{text}\n" }
  end
end
