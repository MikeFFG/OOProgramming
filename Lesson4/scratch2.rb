class BankAccount
  attr_reader :balance

  def initialize(starting_balance)
    @balance = starting_balance
  end

  def positive_balance?
    balance += 1
  end
end

Frank = BankAccount.new(3000)
puts Frank.positive_balance?