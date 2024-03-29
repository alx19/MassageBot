module Client
  module Faq
    def send_faq
      text = [
        "Ответ на наиболее частые вопросы, связанные с сеансами массажа:\n",
        "1. Надо что-то взять с собой?",
        "Ничего не нужно. А так как я делаю массаж с тальком, то можно не переживать за чистоту одежды или волос.",
        "Если делаем массаж всего тела или ног, есть пожелание: стринги и слипы безусловно выигрывают у боксеров и семейников, актуально для любых гендеров\n",
        "2. Как подготовиться?",
        "Никак. Достаточно прочитать список противопоказаний и убедиться, что их у вас нет\n",
        "3. Как все проходит?",
        "В начале обсуждаем пожелания и проблемные зоны, после массажа можно ещё немного полежать на кушетке или посидеть и попить чай\n",
        "4. Мне обычно больно/щекотно на массаже.",
        "Я умею делать так, чтобы не было больно, напряжённо, щекотно. Главное - говорить о любом неудобстве\n",
        "6. У меня небритые ноги/кривые мизинцы/растяжки/шрамы/борода некрасиво подстрижена.",
        "Who cares? Я - точно нет)\n",
        "7. У меня прыщи.",
        "Если это угревая сыпь в активной фазе с сильными воспалениями — я бы советовала от массажа воздержаться, чтобы не вызвать обострения. Если любые менее серьёзные штуки — ничего страшного.\n",
        "8. У меня менструация",
        "Это не противопоказание для массажа, мне в процессе сеанса это мешать не будет. Ориентируйтесь только на свой комфорт.\n",
        "9. У меня сколиоз/плоскостопие/перекос таза/остеохондроз, массаж мне поможет?",
        "Снять мышечное напряжение, уменьшить болезненные ощущения и улучшить качество жизни — да. Исправить костную структуру и излечить вас — этого не могу ни я, ни один другой массажист.\n",
        "10. Я не люблю раздеваться перед незнакомыми людьми. ",
        "Можем сделать массаж шейно-воротниковой зоны или рефлексо-массаж(стопы, ладони, голова). Вы расслабитесь и решите, комфортно ли вам прийти на более масштабный массаж.\n",
        "11. Говорить обязательно?",
        "Как хочется. Можем молчать, могу вас слушать, могу рассказывать разное — решаете только вы\n",
        "12. Я — «все что угодно френдли»(с)"
      ]

      @bot.api.send_message(chat_id: @chat_id, text: text.join("\n"))
    end
  end
end

