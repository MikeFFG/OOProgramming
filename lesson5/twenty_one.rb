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
    answer = gets.chomp
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
    prompt "#{hand.last}"
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
    values.select { |value| value == "A" }.count.times do
      sum -= 10 if sum > 21
    end

    sum
  end

  def display_total
    prompt "#{name}'s total = #{total}"
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

  def display_initial_cards
    prompt "#{name} shows: #{hand[0]} and #{hand[1]}"
  end

  def stay
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
    player.hand[0]= deck.deal
    dealer.hand[0] = deck.deal
    player.hand[1] = deck.deal
    dealer.hand[1] = deck.deal
  end

  def display_initial_cards
    dealer.display_initial_cards
    player.display_initial_cards
  end

  def ask_player_for_action
    answer = nil
    prompt "Hit or Stay? (h or s)"
    loop do
      answer = gets.chomp.downcase
      break if ['h','s'].include?(answer)
      prompt "Invalid Entry. Please enter h or s only."
    end
    answer
  end

  def player_turn
  end

  def dealer_turn

  end

  def show_result

  end

  def start
    clear_screen
    display_welcome_message
    display_press_key_to_start

    clear_screen
    deal_cards
    display_initial_cards
    player.display_total

    loop do
      # player_turn
      if ask_player_for_action == 'h'
        player.hit(deck.deal)
        player.display_hit
        if player.busted?
          break
        end
      else
        prompt "Player Stays"
        break
      end
      player.display_total
    end
    if player.busted?
      prompt "You busted!"
    else
      prompt "Dealer's turn now."
      dealer.display_cards
      loop do
        #dealer_turn
        
        if dealer.total < 17
          dealer.hit(deck.deal)
          # dealer.display_hit
          if dealer.busted?
            break
          end
        else
          prompt "Dealer Stays"
          break
        end
      end
    end
    show_result
  end
end

Game.new.start