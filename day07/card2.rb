class Card2
  attr_reader :value

  ORDERING = ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J'].reverse.freeze

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