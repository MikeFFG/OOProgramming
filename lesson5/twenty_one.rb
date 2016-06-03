require 'pry'

class Participant
  attr_accessor :hand, :name

  def initialize(name)
    @name = name
    @hand = []
  end

  def hit(card)
    hand << card
  end

  def display_hit
    puts "#{hand.last}"
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
    puts "#{name}'s total = #{total}"
  end

  def busted?
    total > 21
  end
end

class Player < Participant
  def initialize(name = "Player")
    super
  end

  def show_initial_cards
    puts "#{name} shows: #{hand[0]} and #{hand[1]}"
  end

  def stay
  end
end

class Dealer < Participant
  def initialize(name = "Dealer")
    super
  end

  def show_initial_cards
    puts "#{name} shows: #{hand[0]} and unknown card"
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

  def show_initial_cards
    dealer.show_initial_cards
    player.show_initial_cards
  end

  def ask_player_for_action
    answer = nil
    puts "Hit or Stay? (h or s)"
    loop do
      answer = gets.chomp.downcase
      break if ['h','s'].include?(answer)
      puts "Invalid Entry. Please enter h or s only."
    end
    answer
  end

  def player_turn
  end

  def dealer_turn

  end

  def show_result

  end

  def clear
    system 'clear'
  end

  def start
    clear
    deal_cards
    show_initial_cards
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
        puts "Player Stays"
        break
      end
      player.display_total
    end
    if player.busted?
      puts "You busted!"
    else
      loop do
        #dealer_turn
        if dealer.total < 17
          dealer.hit(deck.deal)
          dealer.display_hit
          if dealer.busted?
            break
          end
        else
          puts "Dealer Stays"
          break
        end
      end
    end
    show_result
  end
end

Game.new.start