class MyLogger
  def initialize(file = 'log.txt')
    @file = file
  end

  def log_error(error, message_text = '')
    File.open(@file, 'a') { |f| f.write "#{Time.now}: #{error}, message_text: #{message_text}\n" }
  end

  def log(text)
    File.open(@file, 'a') { |f| f.write "#{Time.now}: #{text}\n" }
  end
end
