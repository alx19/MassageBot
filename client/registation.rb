module Registration
  def greetings
    @bot.api.send_message(
      chat_id: @chat_id, text: "Вы не зарегистрировались, давайте пройдем регистрацию.\nКак вас зовут?"
    )
  end

  def info
    MongoClient.user_info(@chat_id)
  end

  def not_registred?
    @info == {} || @info.nil?
  end
end
