require './card'

class Hand
  attr_reader :input, :bid
  attr_accessor :rank

  FIVE_OF_A_KIND = 7
  FOUR_OF_A_KIND = 6
  FULL_HOUSE = 5
  THREE_OF_A_KIND = 4
  TWO_PAIRS = 3
  ONE_PAIR = 2
  HIGH_CARD = 1

  def initialize(input, bid)
    @input = input
    @bid = bid
  end

  def cards
    @cards ||= input.split('').map {|c| Card.new(c)}
  end

  def histo
    @histo ||= begin
                 result = {}
                 result.default = 0
                 cards.reduce(result) do |memo, card|
                   memo[card.value] += 1
                   memo
                 end
                 result.values.sort.reverse
               end
  end

  def type
    @type ||= begin
                case histo
                when [5]
                  FIVE_OF_A_KIND
                when [4, 1]
                  FOUR_OF_A_KIND
                when [3, 2]
                  FULL_HOUSE
                when [3, 1, 1]
                  THREE_OF_A_KIND
                when [2, 2, 1]
                  TWO_PAIRS
                when [2, 1, 1, 1]
                  ONE_PAIR
                else
                  HIGH_CARD
                end
              end
  end

  def winnings
    @winnnings ||= rank.nil? ? nil : rank * bid
  end

  def <=>(other)
    if self.type < other.type
      -1
    elsif self.type > other.type
      1
    else
      self.cards.zip(other.cards)
          .map {|pair| pair[0] <=> pair[1]}
          .reject {|compare| compare == 0}
          .first
    end
  end

  def to_s
    "#{input} #{cards.join} (#{type}) => #{winnings}"
  end
end
