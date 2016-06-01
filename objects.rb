module Study

end

module Outer
  class MyClass
    include Study
  end
end

my_obj = Outer::MyClass.new

puts Outer::MyClass.ancestors
