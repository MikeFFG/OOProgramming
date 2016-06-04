# frozen_string_literal: true
require 'pry'

module Displayable
  def clear_screen
    system('clear') || system('cls')
  end

  def prompt(msg)
    puts "=> #{msg}"
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
end

class Participant
  include Displayable
  attr_accessor :hand, :name

  def initialize(name)
    @name = name
    @hand = []
  end

  def hit(card)
    hand << card
  end

  def display_hit
    hand.last.to_s
  end

  def total
    # binding.pry
    values = hand.map { |card| card.face }
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

  def display_total
    prompt "#{name}'s total is #{total}"
  end

  def busted?
    total > 21
  end

  def display_cards
    string_to_display = "#{name} shows: " + concatenate_cards(hand)
    prompt string_to_display
  end
end

class Player < Participant
  def initialize(name = "Player")
    super
  end

  def stay
  end

  def turn(deck)
    display_turn_start

    loop do
      puts "Hit or Stay? (h or s)"
      answer = nil
      loop do
        answer = gets.chomp.downcase
        break if ['h', 's'].include?(answer)
        prompt "Invalid entry. Enter 'h' or 's' only."
      end
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

  def stay
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
    Card::SUITS.each do |suit|
      Card::FACES.each do |face|
        @cards << Card.new(face, suit)
      end
    end
    shuffle!
  end

  def shuffle!
    @cards.shuffle!
  end

  def deal
    @cards.shift
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

  def display_initial_cards
    dealer.display_initial_cards
    player.display_cards
  end

  def show_result
    prompt detect_result
  end

  def detect_result
    if player.total > 21
      "#{player.name} busted! #{dealer.name} wins!"
    elsif player.total <= 21 && player.total > dealer.total
      "#{player.name} won!"
    elsif dealer.total > 21
      "#{dealer.name} busted! #{player.name} wins!"
    elsif dealer.total <= 21 && dealer.total > player.total
      "#{dealer.name} won!"
    else
      "It's a push!"
    end
  end

  def play
    clear_screen
    display_welcome_message
    display_press_key_to_start

    clear_screen
    deal_cards
    display_initial_cards
    player.display_total

    player.turn(deck)
    if !player.busted?
      dealer.turn(deck)
      display_compare_cards
    end
    show_result
  end
end

Game.new.play
