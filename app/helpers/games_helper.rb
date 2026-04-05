module GamesHelper
  def condition_options
    Game.conditions.keys.map { |k| [k.humanize, k] }
  end

  def playtime_range(min, max)
    [min, max].compact.join("–").then { |s| s.present? ? "#{s} min" : "" }
  end

  def player_range(min, max)
    [min, max].compact.join("–")
  end
end
