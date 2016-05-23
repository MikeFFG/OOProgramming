class MyCar
  attr_accessor :color
  attr_reader :year

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @current_speed = 0
  end

  def self.calculate_gas_mileage(miles, gallons)
    puts "#{miles / gallons} miles per gallon of gas."
  end

  def spray_paint(color)
    self.color = color
    puts "Your new #{color} paint job looks great!"
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

  def to_s
    puts "This car is a #{color} #{year} #{@model}."
  end
end

Cruze = MyCar.new("2013", "blue", "Cruze")
puts Cruze