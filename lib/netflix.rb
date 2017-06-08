class Netflix < MovieCollection
  class NotEnoughMoney < RuntimeError; end
  class NoPeriodSelected < RuntimeError; end

  attr_reader :money
  PRICE = { ancient: 1, classic: 1.5, modern: 3, new: 5 }

  def initialize(file_name)
    super(file_name)
    @money = 0
  end

  def pay(amount)
    @money += amount
  end

  def how_much?(title)
    PRICE[filter(title: title).first.period]
  end

  def show(facets = {})
    raise NoPeriodSelected if facets[:period].nil?
    withdraw(PRICE[facets[:period]])
    movie = filter(facets).sample
    puts "Now showing: #{movie.title}"
    movie
  end

  private

  def withdraw(amount)
    raise NotEnoughMoney if @money < amount
    @money -= amount
  end

end