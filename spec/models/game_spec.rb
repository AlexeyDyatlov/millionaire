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
      generate_questions(60)

      game = nil

      expect {
        game = Game.create_game_for_user!(user)}.to change(Game, :count).by(1).and(
        change(GameQuestion, :count).by(15).and(change(Question, :count).by(0)))

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    it 'answer correct continues game' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question

      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)
      expect(game_w_questions.current_game_question).not_to eq(q)
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

    it '.current_game_question should return current level question' do
      expect(game_w_questions.current_game_question).to eq(game_w_questions.game_questions[0])
    end

    it '.previous_level should return previous_level number' do
      game_w_questions.current_level = 10
      expect(game_w_questions.previous_level).to eq(9)
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

  context '#answer_current_question!' do
    subject { game_w_questions.answer_current_question!(answer) }
    let(:answer) { game_w_questions.current_game_question.correct_answer_key }

    context 'answer was right' do
      context 'question not last in game' do
        it 'should continue the game & change level' do
          expect{ subject }.to change(game_w_questions, :current_level).by(1)
          expect(subject).to be_truthy
          expect(game_w_questions.status).to eq(:in_progress)
        end
      end

      context 'last question in the game' do
        before { game_w_questions.current_level = 14 }

        it 'should finished the game & give 1_000_000 prize' do
          expect{ subject }.to change(game_w_questions, :current_level).by(1)
          expect(game_w_questions.finished?).to be_truthy
          expect(game_w_questions.status).to eq(:won)
          expect(game_w_questions.prize).to eq(1_000_000)
        end
      end

      context 'answer after timeout' do
        before { game_w_questions.created_at = 1.hour.ago }

        it 'change game status to timeout & finished the game' do
          expect{ subject }.to_not change(game_w_questions, :current_level)
          expect(game_w_questions.finished?).to be_truthy
          expect(game_w_questions.status).to eq(:timeout)
        end
      end
    end

    context 'answer was wrong' do
      let(:answer) do
        %w[a b c d].reject { |e| e == super() }.sample
      end

      it 'change game status to fail & finished the game' do
        expect{ subject }.to_not change(game_w_questions, :current_level)
        expect(subject).to be_falsey
        expect(game_w_questions.finished?).to be_truthy
        expect(game_w_questions.status).to eq(:fail)
      end
    end
  end
end
