class Game < ApplicationRecord
  enum :condition, { mint: 0, good: 1, fair: 2, poor: 3, damaged: 4 }

  validates :name, presence: true
  validates :complexity, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validates :enjoyment, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
end
