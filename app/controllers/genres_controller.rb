class GenresController < ApplicationController
  before_action :set_genre, only: %i[edit update destroy]

  def index
    @genres = Genre.order(:name)
  end

  def new
    @genre = Genre.new
  end

  def create
    @genre = Genre.new(genre_params)
    if @genre.save
      redirect_to genres_path, notice: "Genre created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @genre.update(genre_params)
      redirect_to genres_path, notice: "Genre updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @genre.destroy
    redirect_to genres_path, notice: "Genre removed."
  end

  private

  def set_genre
    @genre = Genre.find(params[:id])
  end

  def genre_params
    params.require(:genre).permit(:name)
  end
end
