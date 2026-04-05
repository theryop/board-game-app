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
    @context = params[:context]
    if @genre.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to genres_path, notice: "Genre created." }
      end
    else
      error_target = @context == "game_form" ? "genre_form_error" : "genre_error"
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(error_target, partial: "genres/error", locals: { genre: @genre }) }
        format.html { render :new, status: :unprocessable_content }
      end
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
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to genres_path, notice: "Genre removed." }
    end
  end

  private

  def set_genre
    @genre = Genre.find(params[:id])
  end

  def genre_params
    params.require(:genre).permit(:name)
  end
end
