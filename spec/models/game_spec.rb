require 'rails_helper'
require 'support/my_spec_helper.rb'

RSpec.describe Game, type: :model do
  # Пользователь для создания игр
  let(:user) { FactoryBot.create(:user) }

  # Игра с вопросами для проверки работы
  let(:game_w_questions) do
    FactoryBot.create(:game_with_questions, user: user)
  end

  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      # Используем метод: создадим 60 вопросов, чтобы проверить работу
      # RANDOM при создании игры.
      generate_questions(60)

      game = nil

      # Создали игру, обернули в блок, на который накладываем проверки
      # Смотрим, как этот блок кода изменит базу
      expect {
        game = Game.create_game_for_user!(user)
        # Проверка: Game.count изменился на 1 (создали в базе 1 игру)
      }.to change(Game, :count).by(1).and(
        # GameQuestion.count +15
        change(GameQuestion, :count).by(15).and(
          # Game.count не должен измениться
          change(Question, :count).by(0)))

      # Проверяем юзера и статус
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      # Проверяем, сколько было вопросов
      expect(game.game_questions.size).to eq(15)
      # Проверяем массив уровней
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    # Правильный ответ должен продолжать игру
    it 'answer correct continues game' do
      # Проверяем начальный статус игры
      level = game_w_questions.current_level
      # Текущий вопрос
      q = game_w_questions.current_game_question
      # Проверяем, что статус in_progress
      expect(game_w_questions.status).to eq(:in_progress)

      # Выполняем метод answer_current_question! и сразу передаём верный ответ
      game_w_questions.answer_current_question!(q.correct_answer_key)

      # Проверяем, что уровень изменился
      expect(game_w_questions.current_level).to eq(level + 1)

      # Проверяем, что изменился текущий вопрос
      expect(game_w_questions.current_game_question).not_to eq(q)

      # Проверяем, что игра продолжается/не закончена
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    it 'take_money! finishes the game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      game_w_questions.take_money!

      expect(game_w_questions.status).to eq(:money)
      expect(game_w_questions.finished?).to be_truthy
      expect(game_w_questions.user.balance).to eq game_w_questions.prize
    end

    it '.current_game_question && .previous_level correct' do
      expect(game_w_questions.current_game_question.level).to eq(game_w_questions.current_level)
      expect(game_w_questions.previous_level).to eq(game_w_questions.current_level - 1)
    end

  end

  context '.status' do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end
end
