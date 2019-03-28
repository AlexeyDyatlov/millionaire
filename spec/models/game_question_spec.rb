require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  # Задаем локальную переменную game_question, доступную во всех тестах этого
  # сценария: переменная будет создаваться заново для каждого блока it, где её вызываем
  # Распределяем варианты ответов по-своему
  let(:game_question) do
    FactoryBot.create(:game_question, a:2, b: 1, c: 4, d: 3)
  end

  context 'game status' do
    # Тест на правильную генерацию хеша с вариантами
    it 'correct .variants' do
      # Ожидаем, что варианты ответов будут соответствовать тем,
      # которые мы написали выше
      expect(game_question.variants).to eq(
        'a' => game_question.question.answer2,
        'b' => game_question.question.answer1,
        'c' => game_question.question.answer4,
        'd' => game_question.question.answer3
      )
    end

    # Проверяем метод answer_correct?
    it 'correct .answer_correct?' do
      # Именно под буквой b выше мы спрятали указатель на верный ответ
      expect(game_question.answer_correct?('b')).to be_truthy
    end
  end
end
