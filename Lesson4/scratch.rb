class Cat
  attr_accessor :type, :age

  def initialize(type)
    @type = type
    @age  = 5
  end

  def make_one_year_older
    age >= 1
  end
end

Frank = Cat.new("tabby")
puts Frank.make_one_year_older
