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
    reset
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

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
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
  attr_reader :marker

  def initialize(marker)
    @marker = marker
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

  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  FIRST_TO_MOVE = HUMAN_MARKER

  attr_reader :board, :human, :computer, :score

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
    @score = Score.new
  end

  def play
    clear
    display_welcome_message
    loop do
      loop do
        display_board

        loop do
          current_player_moves
          break if board.someone_won? || board.full?
          clear_screen_and_display_board if human_turn?
        end

        update_score
        break if score.human == 5 || score.computer == 5
        display_round_result
        break unless next_round?
        reset(:round)
        display_new_round_message
      end
      display_match_result
      break unless play_new_match?
      reset(:match)
      display_new_match_message
    end
    display_goodbye_message
  end

  private

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

  def display_score
    human_points_string = get_points_string(:human)
    computer_points_string = get_points_string(:computer)
    puts "You have #{score.human} #{human_points_string}. " \
         "Computer has #{score.computer} #{computer_points_string}."
    puts ""
  end

  def display_new_round_message
    puts "Here we go!"
    puts ""
  end

  def next_round?
    answer = nil
    loop do
      puts "Ready for the next round? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n."
    end

    answer == 'y'
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

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "You're an #{human.marker}. Computer is an #{computer.marker}."
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

  def display_round_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won this round!"
    when computer.marker
      puts "Computer won this round :("
    else
      puts "It's a tie..."
    end
    puts ""
  end

  def display_match_result
    clear_screen_and_display_board
    if score.human == 5
      puts "You win the match! Congratulations!"
    else
      puts "You are a loser..."
    end
    puts ""
  end

  def computer_moves
    chosen_square = find_at_risk_square(computer.marker) ||
                    find_at_risk_square(human.marker) ||
                    board.square_five ||
                    board.unmarked_keys.sample
    board[chosen_square] = computer.marker
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

  def play_new_match?
    answer = nil
    loop do
      puts "Would you like to play a new match? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def reset(type=:match)
    if type == :match
      board.reset
      @current_marker = FIRST_TO_MOVE
      score.human = 0
      score.computer = 0
      clear
    elsif type == :round
      board.reset
      @current_marker = FIRST_TO_MOVE
      clear
    end
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end
end

game = TTTGame.new
game.play
