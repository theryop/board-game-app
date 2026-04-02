class GamesController < ApplicationController
  before_action :set_game, only: %i[edit update destroy]

  def index
    @games = Game.order(:name)
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      redirect_to games_path, notice: "Game added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      redirect_to games_path, notice: "Game updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path, notice: "Game removed."
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(
      :name, :min_players, :max_players, :description,
      :times_played, :bgg_url, :condition, :complexity,
      :min_playtime, :max_playtime, :enjoyment
    )
  end
end
