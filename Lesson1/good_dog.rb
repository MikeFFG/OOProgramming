class GoodDog
  attr_accessor :name, :height, :weight, :age

  @@number_of_dogs = 0

  DOG_YEARS = 7

  def initialize(n, h, w, a)
    @@number_of_dogs += 1
    @name = n
    @height = h
    @weight = w
    self.age = a * DOG_YEARS
  end

  def to_s
    "This dog's name is #{name} and it is #{age} in dog years."
  end

  def self.total_number_of_dogs
    @@number_of_dogs
  end

  def self.what_am_i
    "I'm a GoodDog class!"
  end

  def speak
    "#{name} says arf!"
  end

  def change_info(n, h, w)
    self.name = n
    self.height = h
    self.weight = w
  end

  def info
    "#{self.name} weighs #{self.weight} and is #{self.height} tall."
  end
end

sparky = GoodDog.new("Sparky", 10, 150, 4)
puts sparky           # => 28
