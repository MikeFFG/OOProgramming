# frozen_string_literal: true
require 'pry'

module Displayable
  def clear_screen
    system('clear') || system('cls')
  end

  def prompt(message)
    puts "=> #{message}"
  end

  def display_welcome_message
    prompt "Welcome to Twenty-One!"
    prompt "First player to win 5 rounds wins the game!"
    prompt ""
  end

  def display_press_key_to_start
    prompt "Ready to play? Press enter key to continue."
    gets.chomp
  end

  def concatenate_cards(hand)
    new_string = ''
    hand.each_index do |index|
      new_string += if index == hand.size - 1 && hand.size > 1
                      "and #{hand[index]}."
                    elsif hand.size > 2
                      "#{hand[index]}, "
                    else
                      "#{hand[index]} "
                    end
    end

    new_string
  end

  def display_turn_start
    prompt "==============="
    prompt "#{name}'s turn."
    prompt "==============="
  end

  def display_compare_cards
    prompt "==============="
    dealer.display_total
    player.display_total
    prompt "==============="
  end

  def display_total
    prompt "#{name}'s total is #{total}"
  end

  def display_hit
    hand.last.to_s
  end

  def hit_or_stay
    prompt "Hit or Stay? (h or s)"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ['h', 's'].include?(answer)
      prompt "Invalid entry. Enter 'h' or 's' only."
    end
    answer
  end

  def display_cards
    string_to_display = "#{name} shows: " + concatenate_cards(hand)
    prompt string_to_display
  end

  def display_initial_cards
    dealer.display_initial_cards
    player.display_cards
  end

  def display_result
    display_string = case detect_result
                     when :player_busted
                       "#{player.name} busted! #{dealer.name} wins this round!"
                     when :player_won
                       "#{player.name} wins the round!"
                     when :dealer_busted
                       "#{dealer.name} busted! #{player.name} wins this round!"
                     when :dealer_won
                       "#{dealer.name} wins the round!"
                     when :push
                       "It's a push!"
                     end
    prompt display_string
    prompt "==============="
  end

  def display_score
    prompt "Current score is:"
    prompt "#{player.name}: #{player.score}"
    prompt "#{dealer.name}: #{dealer.score}"
    prompt "==============="
  end

  def display_match_winner
    winner = player.score == 5 ? player : dealer
    prompt ""
    prompt "#{winner.name.upcase} WINS THE MATCH!"
    prompt ""
  end
end

class Participant
  include Displayable
  attr_accessor :hand, :name, :score

  def initialize(name)
    @name = name
    @hand = []
    @score = 0
  end

  def hit(card)
    hand << card
  end

  def total
    values = hand.map(&:face)
    sum = 0
    values.each do |value|
      sum += if value == "Ace"
               11
             elsif value.to_i == 0 # J, Q, K
               10
             else
               value.to_i
             end
    end

    # correct for Aces
    values.select { |value| value == "Ace" }.count.times do
      sum -= 10 if sum > 21
    end

    sum
  end

  def busted?
    total > 21
  end

  def reset_hand
    self.hand = []
  end
end

class Player < Participant
  def initialize(name = "Player")
    super
  end

  def turn(deck)
    display_turn_start
    loop do
      answer = hit_or_stay
      clear_screen
      if answer == 's'
        prompt "#{name} stays!"
        break
      elsif busted?
        break
      else
        hit(deck.deal)
        prompt "#{name} hits and gets a #{display_hit}"
        display_total
        break if busted?
      end
    end
  end
end

class Dealer < Participant
  def initialize(name = "Dealer")
    super
  end

  def display_initial_cards
    prompt "#{name} shows: #{hand[0]} and unknown card"
  end

  def turn(deck)
    display_turn_start
    display_cards

    loop do
      display_total
      if total >= 17 && !busted?
        prompt "Dealer Stays"
        break
      elsif busted?
        break
      else
        hit(deck.deal)
        prompt "#{name} hits and gets a #{display_hit}"
      end
    end
  end
end

class Deck
  def initialize
    @cards = []
    reset
    shuffle!
  end

  def shuffle!
    @cards.shuffle!
  end

  def deal
    reset if @cards.size < 10
    @cards.shift
  end

  def reset
    Card::SUITS.each do |suit|
      Card::FACES.each do |face|
        @cards << Card.new(face, suit)
      end
    end
  end
end

class Card
  SUITS = ['Hearts', 'Spades', 'Clubs', 'Diamonds'].freeze
  FACES = ['Ace', '2', '3', '4', '5', '6', '7'] +
          ['8', '9', '10', 'Jack', 'Queen', 'King'].freeze

  attr_accessor :face, :suit

  def initialize(face, suit)
    @face = face
    @suit = suit
  end

  def to_s
    "#{@face} of #{@suit}"
  end
end

class Game
  include Displayable
  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def deal_cards
    player.hand[0] = deck.deal
    dealer.hand[0] = deck.deal
    player.hand[1] = deck.deal
    dealer.hand[1] = deck.deal
  end

  def detect_result
    player_total = player.total
    dealer_total = dealer.total

    if player_total > dealer_total
      return :player_busted if player_total > 21
      :player_won
    elsif dealer_total > player_total
      return :dealer_busted if dealer_total > 21
      :dealer_won
    else
      :push
    end
  end

  def update_score
    if detect_result == :player_won || detect_result == :dealer_busted
      player.score += 1
    elsif detect_result == :dealer_won || detect_result == :player_busted
      dealer.score += 1
    end
  end

  def next_game?(type)
    prompt "Ready for a new #{type}? (y or n)"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      prompt "Invalid entry. Enter 'y' or 'n' only."
    end

    return true if answer == 'y'
    false
  end

  def reset_hands
    player.reset_hand
    dealer.reset_hand
  end

  # rubocop:disable Metrics/AbcSize
  def play_single_round
    deal_cards
    display_initial_cards
    player.display_total

    player.turn(deck)
    if !player.busted?
      dealer.turn(deck)
      display_compare_cards unless dealer.busted?
    end

    display_result
    update_score
  end
  # rubocop:enable Metrics/AbcSize

  def match_winner?
    player.score == 5 || dealer.score == 5
  end

  def early_quit
    prompt "You didn't finish the match. Do you want to start again? (y or n)"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      prompt "Invalid entry. Please enter only 'y' or 'n'"
    end
    answer
  end

  def reset_match
    reset_hands
    player.score = 0
    dealer.score = 0
    deck.reset
  end

  def start
    clear_screen
    display_welcome_message
    display_press_key_to_start
    loop do
      loop do
        clear_screen
        play_single_round
        reset_hands
        display_score
        break if match_winner?
        break unless next_game?(:round)
      end
      if match_winner?
        display_match_winner
        break unless next_game?(:match)
      elsif early_quit == 'n'
        break
      end
      reset_match
    end

    prompt "Thanks for playing Twenty-One. Goodbye!"
  end
end

Game.new.start
