class Student
  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(other_student)
    grade > other_student.grade
  end

  protected

  def grade
    @grade
  end
end

joe = Student.new('joe', 99)
bob = Student.new('bob', 92)
puts "Well done!" if joe.better_grade_than?(bob)
