require "rails_helper"

RSpec.describe "Game genre tagging", type: :request do
  describe "GET /games" do
    it "displays the genres for each game" do
      strategy = create(:genre, name: "Strategy")
      game = create(:game, name: "Chess")
      game.genres << strategy

      get "/games"

      expect(response.body).to include("Strategy")
    end
  end

  describe "POST /games with no genres" do
    it "saves the game with zero genres" do
      expect {
        post "/games", params: { game: { name: "Solo Game" } }
      }.to change(Game, :count).by(1)

      expect(Game.last.genres).to be_empty
    end
  end

  describe "PATCH /games/:id" do
    it "replaces genre associations" do
      strategy = create(:genre, name: "Strategy")
      party    = create(:genre, name: "Party")
      game = create(:game, name: "Catan", genre_ids: [ strategy.id ])

      patch "/games/#{game.id}", params: { game: { genre_ids: [ party.id ] } }

      expect(game.reload.genres).to contain_exactly(party)
    end
  end

  describe "DELETE /genres/:id" do
    it "removes the genre from associated games without destroying the game" do
      strategy = create(:genre, name: "Strategy")
      game = create(:game, name: "Chess")
      game.genres << strategy

      delete "/genres/#{strategy.id}"

      expect(game.reload.genres).to be_empty
      expect(Game.exists?(game.id)).to be true
    end
  end

  describe "POST /games with genre IDs" do
    it "saves the genre associations" do
      strategy = create(:genre, name: "Strategy")
      party    = create(:genre, name: "Party")

      post "/games", params: { game: { name: "Catan", genre_ids: [ strategy.id, party.id ] } }

      game = Game.last
      expect(game.genres).to contain_exactly(strategy, party)
    end
  end
end
