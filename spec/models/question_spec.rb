require 'rails_helper'

RSpec.describe Question, type: :model do
  subject { Question.new(text: 'some', level: 0, answer1: '1', answer2: '1', answer3: '1', answer4: '1') }
  context 'validations check' do
    # Проверяем наличие валидации
    it { should validate_presence_of :level }
    it { should validate_presence_of :text }
    # Проверяем, что уровень входит в диапазон
    it { should validate_inclusion_of(:level).in_range(0..14) }

    # Проверяем, что модель не разрешает значение 500
    it { should_not allow_value(500).for(:level) }
    # Проверяем, разрешает ли наша модель значение 14
    it { should allow_value(14).for(:level) }
    it { should validate_uniqueness_of :text }
  end
end
