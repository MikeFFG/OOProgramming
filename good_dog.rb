class GoodDog
  attr_accessor :name, :height, :weight

  @@number_of_dogs = 0

  def initialize(n, h, w)
    @@number_of_dogs += 1
    @name = n
    @height = h
    @weight = w
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

puts GoodDog.total_number_of_dogs   # => 0

dog1 = GoodDog.new("bob", 36, 145)
dog2 = GoodDog.new("dave", 12, 145)

puts GoodDog.total_number_of_dogs   # => 2
