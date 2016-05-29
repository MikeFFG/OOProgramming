# frozen_string_literal: true
require 'pry'
class Score
  attr_accessor :human_score, :computer_score

  def initialize
    @human_score = 0
    @computer_score = 0
  end

  def calculate_score(winner)
    case winner
    when :human
      @human_score += 1
    when :computer
      @computer_score += 1
    end
  end
end

class Move
  attr_accessor :value
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock'].freeze
  WINS = {
    'rock' => %w(scissors lizard),
    'paper' => %w(rock spock),
    'scissors' => %w(paper lizard),
    'lizard' => %w(paper spock),
    'spock' => %w(rock scissors)
  }.freeze

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def paper?
    @value == 'paper'
  end

  def rock?
    @value == 'rock'
  end

  def lizard?
    @value == 'lizard'
  end

  def spock?
    @value == 'spock'
  end

  def >(other_move)
    WINS[@value].include?(other_move.value)

    # rock? && other_move.scissors? ||
    #   rock? && other_move.lizard? ||
    #   scissors? && other_move.paper? ||
    #   scissors? && other_move.lizard? ||
    #   paper? && other_move.rock? ||
    #   paper? && other_move.spock? ||
    #   lizard? && other_move.paper? ||
    #   lizard? && other_move.spock? ||
    #   spock? && other_move.rock? ||
    #   spock? && other_move.scissors?
  end

  def <(other_move)
    WINS[other_move.value].include?(@value)
    # rock? && other_move.paper? ||
    #   rock? && other_move.spock? ||
    #   scissors? && other_move.rock? ||
    #   scissors? && other_move.spock? ||
    #   paper? && other_move.scissors? ||
    #   paper? && other_move.lizard? ||
    #   lizard? && other_move.scissors? ||
    #   lizard? && other_move.rock? ||
    #   spock? && other_move.lizard? ||
    #   spock? && other_move.paper?
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name

  def initialize
    set_name
    clear_screen
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, you must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard or spock:"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer, :score

  def initialize
    @human = Human.new
    @computer = Computer.new
    @score = Score.new
  end

  def self.display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  end

  def self.display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Goodbye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner(winner)
    case winner
    when :human
      puts "#{human.name} won the round!"
    when :computer
      puts "#{computer.name} won the round!"
    when :tie
      puts "It's a tie!"
    end
  end

  def display_score
    puts "#{human.name} has #{score.human_score} points."
    puts "#{computer.name} chose #{score.computer_score} points."
  end

  def display_game_winner
    if score.human_score == 10
      puts "#{human.name} wins the game!"
    elsif score.computer_score == 10
      puts "#{computer.name} wins the game!"
    end
  end

  def self.play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must be y or n."
    end

    return false if answer.casecmp('n') == 0
    return true if answer.casecmp('y') == 0
  end

  def calculate_winner
    if human.move > computer.move
      :human
    elsif human.move < computer.move
      :computer
    else
      :tie
    end
  end

  def play
    loop do
      human.choose
      computer.choose
      clear_screen
      display_moves
      winner = calculate_winner
      display_winner(winner)
      score.calculate_score(winner)
      display_score
      break if score.human_score == 10 || score.computer_score == 10
    end
  end
end

def clear_screen
  system('clear') || system('cls')
end

clear_screen
RPSGame.display_welcome_message

loop do
  game = RPSGame.new
  game.play
  game.display_game_winner
  break unless RPSGame.play_again?
end

RPSGame.display_goodbye_message
