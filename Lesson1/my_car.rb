module Towable
  def can_tow?(pounds)
    pounds < 2000 ? true : false
  end
end

class Vehicle
  attr_accessor :color
  attr_reader :year, :model

  @@number_of_vehicles = 0

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @current_speed = 0
    @@number_of_vehicles += 1
  end

  def self.total_number_of_vehicles
    @@number_of_vehicles
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
    puts "Vehicle is shut off now."
  end

  def current_speed
    puts "You are now going #{@current_speed} mph."
  end

end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4

  def to_s
    puts "This car is a #{color} #{year} #{@model}."
  end
end

class MyTruck < Vehicle
  include Towable
  NUMBER_OF_DOORS = 2

  def to_s
    puts "This truck is a #{color} #{year} #{@model}."
  end
end

Cruze = MyCar.new("2013", "blue", "Cruze")
Truck = MyTruck.new("2000", "black", "whatever")

Cruze.speed_up(50)
Cruze.brake(20)
Cruze.current_speed
Cruze.shut_off
Cruze.spray_paint("green")