module MySpecHelper
  # Метод нужное число раз дёрнет factory_girl
  # и создаст новый объект вопроса в базе
  def generate_questions(number)
    number.times do
      FactoryBot.create(:question)
    end
  end
end

# Это строка для подключения метода к тестам
RSpec.configure do |c|
  c.include MySpecHelper
end
