FactoryBot.define do
  factory :game_question do
    # Всегда одинаковое распределение ответов, в тестах это удобнее
    # В d всегда верный
    a { 4 }
    b { 3 }
    c { 2 }
    d { 1 }

     # association — ключевое слово гема
    # Устанавливает связь с игрой и вопросом. Если при создании game_question не указать явно
    # объекты Игра и Вопрос, то фабрика сама создаст и пропишет нужные
    # объекты, найдя их среди созданных фабрик по именам (game и question)
    association :game
    association :question
  end
end
