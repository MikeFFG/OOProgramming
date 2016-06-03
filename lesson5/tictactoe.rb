# frozen_string_literal: true
require 'pry'

module OutputHelpers
  def joinor(array, delimiter = ',', word = 'or')
    new_string = ''
    array.each_index do |num|
      new_string += if num == array.length - 1 && array.length > 1
                      "#{word} #{array[num]}"
                    elsif array.length > 2
                      "#{array[num]}#{delimiter} "
                    else
                      "#{array[num]} "
                    end
    end

    new_string
  end
end

module Displayable
  def clear_screen
    system('clear') || system('cls')
  end

  def display_choose_first_player_message
    puts "Who should make the first move?" \
         " Type #{human.name} or #{computer.name}."
  end

  def display_score
    human_points_string = human.points_string
    computer_points_string = computer.points_string
    puts "You have #{human.score} #{human_points_string}.\n" \
         "#{computer.name} has #{computer.score} #{computer_points_string}."
    puts ""
  end

  def display_new_round_message
    puts "Here we go!"
    puts ""
  end

  def display_rules
    puts "First player to win 5 rounds wins the game."
    puts ""
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
    display_rules
  end

  def display_board_and_clear_screen
    clear_screen
    display_board
  end

  def display_board
    puts "#{human.name} is: #{human.marker}"
    puts "#{computer.name} is: #{computer.marker}"
    puts ""
    puts display_score
    board.draw
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe. Goodbye!"
  end

  def display_new_match_message
    puts "Let's play again!"
    puts ""
    display_rules
  end

  def display_round_result
    display_board_and_clear_screen

    case board.winning_marker
    when human.marker
      puts "You won this round!"
    when computer.marker
      puts "#{computer.name} won this round :("
    else
      puts "It's a tie..."
    end

    puts ""
  end

  def display_match_result
    display_board_and_clear_screen
    if human.score == 5
      puts "You win the match, #{human.name}! Congratulations!"
    elsif human.forfeited == true
      puts "You forfeited the match, #{human.name}. You chicken???"
      human.forfeited = false
    else
      puts "You lost the match, #{human.name}. You are SUCH a loser..."
    end
  end
end

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +   # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +   # cols
                  [[1, 5, 9], [3, 5, 7]]                # diagonals

  def initialize
    @squares = {}
    reset_board
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end

    nil
  end

  def marker_count(line, marker)
    markers = 0
    line.each do |square|
      markers += 1 if @squares[square].marker == marker
    end

    markers
  end

  def square_value(line, marker)
    value = nil
    line.each do |square|
      value = square if @squares[square].marker == marker
    end

    value
  end

  def square_five
    return 5 if unmarked_keys.include?(5)
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  def reset_board
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def find_at_risk_square(marker)
    square = nil
    WINNING_LINES.each do |line|
      if marker_count(line, marker) == 2 &&
         marker_count(line, Square::INITIAL_MARKER) == 1
        square = square_value(line, Square::INITIAL_MARKER)
        break
      else
        square = false
      end
    end

    square
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = ' '
  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  include OutputHelpers
  attr_accessor :marker, :name, :forfeited, :score

  def initialize(marker, name)
    @marker = marker
    @name = name
    @forfeited = false
    @score = 0
  end

  def update_score(board)
    self.score += 1 if board.winning_marker == marker
  end

  def points_string
    self.score == 1 ? "point" : "points"
  end
end

class Human < Player
  def pick_marker
    puts "Choose any single character as a marker (besides 'O')." \
         " The default is 'X'."
    answer = nil
    loop do
      answer = gets.strip
      break if answer != 'O' && answer.size == 1
      puts "Invalid entry. Please enter only a single " \
           "character that is not a capital 'O'."
    end

    self.marker = answer
  end

  def set_name
    puts "Enter your name. Leave blank and hit enter for the default: 'Player'"
    answer = gets.strip
    self.name = answer.empty? ? 'Player' : answer
    puts "Hi #{name}!"
  end

  def moves(board)
    puts "Choose a square: #{joinor(board.unmarked_keys)}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = marker
  end

  def turn?(current_marker)
    current_marker == marker
  end
end

class Computer < Player
  def set_name
    puts "Enter a computer name." \
         " Leave blank and hit enter for the default: 'Computer'"
    answer = gets.strip
    self.name = answer.empty? ? 'Computer' : answer
  end

  def move(board, human)
    chosen_square = board.find_at_risk_square(marker) ||
                    board.find_at_risk_square(human.marker) ||
                    board.square_five ||
                    board.unmarked_keys.sample
    board[chosen_square] = marker
  end
end

class TTTGame
  include OutputHelpers
  include Displayable

  DEFAULT_HUMAN_MARKER = 'X'
  DEFAULT_COMPUTER_MARKER = 'O'

  attr_reader :board, :human, :computer, :first_player

  def initialize
    @board = Board.new
    @human = Human.new(DEFAULT_HUMAN_MARKER, 'Player')
    @computer = Computer.new(DEFAULT_COMPUTER_MARKER, 'Computer')
    @current_marker = DEFAULT_HUMAN_MARKER
    @first_player = human.marker
    @first_iteration = true
  end

  def play
    clear_screen
    display_welcome_message
    loop do
      choose_settings
      single_match_logic
      display_match_result
      break unless play_new_match?
      reset(:match)
      display_new_match_message
    end

    display_goodbye_message
  end

  private

  ### Settings ###
  def choose_settings
    if ask_user_to_choose_settings == 'y'
      clear_screen
      human.set_name
      computer.set_name
      human.pick_marker
      choose_first_player
    end
  end

  def ask_user_to_choose_settings
    if @first_iteration == true
      puts "Would you like any custom settings? (y or n)"
      @first_iteration = false
    else
      puts "Would you like to update your settings? (y or n)"
    end

    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Invalid entry. Please enter y or n only."
    end

    answer
  end

  # rubocop:disable Metrics/AbcSize
  def choose_first_player
    display_choose_first_player_message
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if [human.name.downcase, computer.name.downcase].include?(answer)
      puts "Invalid entry. Please enter either " \
           "#{human.name} or #{computer.name}"
    end

    assign_first_player(answer)
  end
  # rubocop:enable Metrics/AbcSize

  def assign_first_player(choice)
    @first_player = if choice == human.name.downcase
                      human.marker
                    else
                      computer.marker
                    end

    @current_marker = @first_player
  end

  ### Logic ###
  def single_round_logic
    display_board_and_clear_screen
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      display_board_and_clear_screen if human.turn?(@current_marker)
    end

    human.update_score(board)
    computer.update_score(board)
  end

  def single_match_logic
    loop do
      single_round_logic
      break if human.score == 5 || computer.score == 5
      display_round_result
      break unless next_round?
      reset(:round)
      display_new_round_message
    end
  end

  def current_player_moves
    if human.turn?(@current_marker)
      human.moves(board)
      @current_marker = computer.marker
    else
      computer.move(board, human)
      @current_marker = human.marker
    end
  end

  ### New Game Methods ###
  def play_new_match?
    answer = nil
    loop do
      puts "Would you like to play a new match? (y or n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def next_round?
    answer = nil
    loop do
      puts "Ready for the next round? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n."
    end

    human.forfeited = true if answer == 'n'
    answer == 'y'
  end

  def reset(type=:match)
    if type == :match
      human.score = 0
      computer.score = 0
    end

    board.reset_board
    @current_marker = @first_player
    human.forfeited = false
    clear_screen
  end
end

game = TTTGame.new
game.play
