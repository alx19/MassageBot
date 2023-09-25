class MessageHandler
  attr_reader :message, :bot, :course

  def initialize(message:, bot:)
    @message = message
    @bot = bot
  end

  def perform
    return handle_payment if is_payment?
    return handle_master if message_from_master?

    handle_client
  rescue => e
    LOGGER.fatal('Caught exception;')
    LOGGER.fatal(e)
  end

  private

  def is_payment?
    message.is_a?(Telegram::Bot::Types::PreCheckoutQuery) || successful_payment?
  end

  def message_from_master?
    message.from.id == MASTER_ID
  end

  def handle_payment
    case
    when message.is_a?(Telegram::Bot::Types::PreCheckoutQuery)
      answer_precheckout
    when successful_payment?
      deliver_product
      notify_master
    end
  end

  def handle_client
    Client::Client.new(message: message, bot: bot).perform
  end

  def handle_master
    Master.new(message: message, bot: bot).perform
  end

  def answer_precheckout
    params = { pre_checkout_query_id: message.id, ok: true }
    Telegram::Bot::Api.new(TOKEN).call('answerPreCheckoutQuery', params)
  end

  def deliver_product
    product = message.successful_payment.invoice_payload
    case
    when product.start_with?("course")
      deliver_course(product)
    when product.start_with?("test")
      bot.api.send_document(chat_id: message.from.id, text: 'поздравляю, вы купили ничего за 200р!')
    end
  end

  def deliver_course(product)
    course_id = product.delete_prefix("course_").to_i
    @course = COURSES[course_id]
    bot.api.send_message(chat_id: message.from.id, text: course.content)
    course.files.each do |file|
      bot.api.send_document(chat_id: message.from.id, document: file.file_id, caption: file.caption)
    end
  end

  def successful_payment?
    message.is_a?(Telegram::Bot::Types::Message) && message.successful_payment
  end

  def notify_master
    user = message.from
    amount = message.successful_payment.total_amount / 100
    username = user.username ? "@#{user.username} " : ''
    bot.api.send_message(chat_id: MASTER_ID, text: "<a href=\"tg://user?id=#{user.id}\">#{user.first_name}</a> #{username}купил курс #{course.title} за #{amount}р 🤑", parse_mode: 'HTML')
  end
end
