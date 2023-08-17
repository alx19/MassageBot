module Client
  module Payments
    class Course < Payment
      CURRENCY = :RUB

      def initialize(bot:, chat_id:, course_id:)
        @course_id = course_id
        @course = COURSES[course_id]
        super(bot: bot, chat_id: chat_id)
      end

      def sell_course
        send_invoice(generate_invoice)
      end

      private

      def generate_invoice
        {
          chat_id: @chat_id,
          title: @course.title,
          description: @course.description,
          payload: "course_#{@course_id}",
          prices: telegram_labeled_price('Курс', @course.price),
          currency: CURRENCY
        }
      end

      def telegram_labeled_price(label, price)
        [Telegram::Bot::Types::LabeledPrice.new(label: label, amount: price * 100)]
      end
    end
  end
end
