class MyCar
  attr_accessor :year, :color, :model, :speed

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @speed = 0
  end

  def speed_up(number)
    self.speed += number
    puts "You push the gas and accelerate #{number} mph."
  end

  def brake(number)
    self.speed -= number
    puts "You push the brake and decelerate #{number} mph."
  end

  def shut_off
    self.speed = 0
    puts "Car is shut off now."
  end

  def current_speed
    puts "You are now going #{self.speed} mph."
  end
end

Cruze = MyCar.new(2014, "blue", "Cruze")
Cruze.speed_up(20)
Cruze.current_speed
Cruze.speed_up(20)
Cruze.current_speed
Cruze.brake(20)
Cruze.current_speed
Cruze.shut_off
Cruze.current_speed