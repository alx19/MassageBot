module Client
  module Payments
    class Payment
      def initialize(bot:, chat_id:)
        @bot = bot
        @chat_id = chat_id
      end

      def send_invoice(data)
        data.merge!(provider_token: ENV['YOO_KASSA_TOKEN'])
        @bot.api.send_invoice(**data)
      end

      def self.send_invoice(bot, data)
        data.merge!(provider_token: ENV['YOO_KASSA_TOKEN'])
        bot.api.send_invoice(**data)
      end

      def process_payment
        raise NotImplementedError, "Subclasses must implement this method"
      end
    end
  end
end
