class Game < ApplicationRecord
  has_many :game_genres, dependent: :destroy
  has_many :genres, through: :game_genres
  belongs_to :base_game, class_name: "Game", optional: true
  has_many :expansions, class_name: "Game", foreign_key: :base_game_id, dependent: :nullify, inverse_of: :base_game

  enum :condition, { mint: 0, good: 1, fair: 2, poor: 3, damaged: 4 }

  validates :name, presence: true
  validates :complexity, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validates :enjoyment, numericality: { only_integer: true, in: 1..5 }, allow_nil: true

  scope :base_games, -> { where(base_game_id: nil) }
  scope :expansions_only, -> { where.not(base_game_id: nil) }
end
