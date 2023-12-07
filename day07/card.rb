class Card
  attr_reader :value

  ORDERING = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'].reverse.freeze

  def initialize(value)
    @value = value
  end

  def <=>(other)
    ORDERING.find_index(value) <=> ORDERING.find_index(other.value)
  end

  def to_s
    "[#{value}]"
  end
end