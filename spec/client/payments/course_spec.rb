require 'spec_helper'

RSpec.describe Client::Payments::Course do
  let(:bot) { double('bot') }
  let(:chat_id) { 123 }
  let(:course_id) { 0 }  # Index of the course in COURSES array

  subject { described_class.new(bot: bot, chat_id: chat_id, course_id: course_id) }

  describe '#sell_course' do
    let(:invoice_payload) { 'test_course_1' }
    let(:expected_invoice) do
      {
        chat_id: chat_id,
        title: Client::Payments::Course::COURSES[course_id][:title],
        description: Client::Payments::Course::COURSES[course_id][:description],
        payload: invoice_payload,
        prices: [Telegram::Bot::Types::LabeledPrice.new(label: 'test', amount: Client::Payments::Course::COURSES[course_id][:price] * 100)],
        currency: Client::Payments::Course::CURRENCY
      }
    end

    it 'sends the correct invoice' do
      expect(subject).to receive(:send_invoice).with(expected_invoice)
      subject.sell_course
    end
  end
end
