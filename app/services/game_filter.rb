class GameFilter
  SORTABLE_COLUMNS = %w[name complexity enjoyment times_played].freeze

  def initialize(params = {})
    @params = params
  end

  def results
    scope = Game.includes(:genres)
    scope = apply_condition_filter(scope)
    scope = apply_genre_filter(scope)
    scope = apply_player_count_filter(scope)
    scope = apply_playtime_filter(scope)
    scope = apply_complexity_filter(scope)
    scope = apply_enjoyment_filter(scope)
    scope = apply_sort(scope)
    scope
  end

  private

  def apply_genre_filter(scope)
    ids = Array(@params[:genre_ids]).map(&:to_i).reject(&:zero?)
    return scope if ids.empty?

    if @params[:genre_mode] == "and"
      ids.each { |id| scope = scope.where(id: GameGenre.select(:game_id).where(genre_id: id)) }
      scope
    else
      scope.where(id: GameGenre.select(:game_id).where(genre_id: ids))
    end
  end

  def apply_condition_filter(scope)
    return scope if @params[:condition].blank?
    return scope unless Game.conditions.key?(@params[:condition])

    scope.where(condition: Game.conditions[@params[:condition]])
  end

  def apply_player_count_filter(scope)
    n = @params[:player_count].to_i
    return scope if n.zero?

    scope.where("min_players <= ? AND max_players >= ?", n, n)
  end

  def apply_playtime_filter(scope)
    max = @params[:max_playtime].to_i
    return scope if max.zero?

    scope.where("min_playtime <= ?", max)
  end

  def apply_complexity_filter(scope)
    val = @params[:complexity].to_i
    return scope if val.zero?

    scope.where(complexity: val)
  end

  def apply_enjoyment_filter(scope)
    val = @params[:enjoyment].to_i
    return scope if val.zero?

    scope.where(enjoyment: val)
  end

  def apply_sort(scope)
    column = SORTABLE_COLUMNS.include?(@params[:sort]) ? @params[:sort] : "name"
    direction = @params[:direction] == "desc" ? "desc" : "asc"
    scope.order(Arel.sql("#{column} #{direction}"))
  end
end
