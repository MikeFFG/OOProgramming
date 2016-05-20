class MyCar
  attr_accessor :color
  attr_reader :year

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @current_speed = 0
  end

  def spray_paint(color)
    self.color = color
    puts "You new #{color} paint job looks great!"
  end

  def speed_up(number)
    @current_speed += number
    puts "You push the gas and accelerate #{number} mph."
  end

  def brake(number)
    @current_speed -= number
    puts "You push the brake and decelerate #{number} mph."
  end

  def shut_off
    @current_speed = 0
    puts "Car is shut off now."
  end

  def current_speed
    puts "You are now going #{@current_speed} mph."
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