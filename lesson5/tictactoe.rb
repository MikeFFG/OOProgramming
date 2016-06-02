# frozen_string_literal: true
require 'pry'

module Utilities
  def joinor(ary, dlm = ',', word = 'or')
    new_string = ''
    ary.each_index do |num|
      new_string += if num == ary.length - 1 && ary.length > 1
                      "#{word} #{ary[num]}"
                    elsif ary.length > 2
                      "#{ary[num]}#{dlm} "
                    else
                      "#{ary[num]} "
                    end
    end
    new_string
  end

  def clear
    system 'clear'
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
  attr_accessor :marker, :name, :forfeited

  def initialize(marker, name)
    @marker = marker
    @name = name
    @forfeited = false
  end
end

class Score
  attr_accessor :human, :computer

  def initialize
    @human = 0
    @computer = 0
  end
end

class TTTGame
  include Utilities

  DEFAULT_HUMAN_MARKER = 'X'
  DEFAULT_COMPUTER_MARKER = 'O'

  attr_reader :board, :human, :computer, :score, :first_player

  def initialize
    @board = Board.new
    @human = Player.new(DEFAULT_HUMAN_MARKER, 'Player')
    @computer = Player.new(DEFAULT_COMPUTER_MARKER, 'Computer')
    @current_marker = DEFAULT_HUMAN_MARKER
    @score = Score.new
    @first_player = human.marker
    @first_iteration = true
  end

  def play
    clear
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
      clear
      set_player_names
      pick_marker
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

  def assign_first_player(choice)
    if choice == human.name.downcase
      @first_player = human.marker
      @current_marker = human.marker
    else
      @first_player = computer.marker
      @current_marker = computer.marker
    end
  end

  def pick_marker
    puts "Choose any single character as a marker (besides 'O')." \
         " The default is 'X'."
    answer = nil
    loop do
      answer = gets.chomp
      break if answer != 'O' && answer.size == 1
      puts "Invalid entry. Please enter only a single " \
           "character that is not a capital 'O'."
    end
    human.marker = answer
  end

  def set_player_names
    puts "Enter your name. Leave blank and hit enter for the default: 'Player'"
    answer = gets.chomp
    human.name = answer.empty? ? 'Player' : answer
    puts "Hi #{human.name}! \nEnter a computer name." \
         " Leave blank and hit enter for the default: 'Computer'"
    answer = gets.chomp
    answer.empty? ? computer.name = 'Computer' : computer.name = answer
  end

  ### Logic ###
  def single_round_logic
    display_board_and_clear_screen
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      display_board_and_clear_screen if human_turn?
    end
    update_score
  end

  def single_match_logic
    loop do
      single_round_logic
      break if score.human == 5 || score.computer == 5
      display_round_result
      break unless next_round?
      reset(:round)
      display_new_round_message
    end
  end

  def find_at_risk_square(marker)
    square = nil
    Board::WINNING_LINES.each do |line|
      if board.marker_count(line, marker) == 2 &&
         board.marker_count(line, Square::INITIAL_MARKER) == 1
        square = board.square_value(line, Square::INITIAL_MARKER)
        break
      else
        square = false
      end
    end
    square
  end

  ### Turns ###
  def human_moves
    puts "Choose a square: #{joinor(board.unmarked_keys)}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    chosen_square = find_at_risk_square(computer.marker) ||
                    find_at_risk_square(human.marker) ||
                    board.square_five ||
                    board.unmarked_keys.sample
    board[chosen_square] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
  end

  ### Scoring ###
  def update_score
    case board.winning_marker
    when human.marker
      score.human += 1
    when computer.marker
      score.computer += 1
    end
  end

  def get_points_string(player)
    if player == :human
      return "points" unless score.human == 1
    end
    if player == :computer
      return "points" unless score.computer == 1
    end
    "point"
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
      score.human = 0
      score.computer = 0
    end
    board.reset_board
    @current_marker = @first_player
    human.forfeited = false
    clear
  end

  #### DISPLAY ####
  def display_choose_first_player_message
    puts "Who should make the first move?" \
         " Type #{human.name} or #{computer.name}."
  end

  def display_score
    human_points_string = get_points_string(:human)
    computer_points_string = get_points_string(:computer)
    puts "You have #{score.human} #{human_points_string}.\n" \
         "#{computer.name} has #{score.computer} #{computer_points_string}."
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
    clear
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
    if score.human == 5
      puts "You win the match, #{human.name}! Congratulations!"
    elsif human.forfeited == true
      puts "You forfeited the match, #{human.name}. You chicken???"
      human.forfeited = false
    else
      puts "You lost the match, #{human.name}. You are SUCH a loser..."
    end
  end
end

game = TTTGame.new
game.play
