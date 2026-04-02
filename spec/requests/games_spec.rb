require "rails_helper"

RSpec.describe "Games", type: :request do
  describe "POST /games" do
    it "creates a game and redirects when params are valid" do
      expect {
        post "/games", params: { game: { name: "Ticket to Ride", times_played: 0 } }
      }.to change(Game, :count).by(1)

      expect(response).to redirect_to(games_path)
    end

    it "does not create a game when name is missing" do
      expect {
        post "/games", params: { game: { name: "" } }
      }.not_to change(Game, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does not create a game when complexity is out of range" do
      expect {
        post "/games", params: { game: { name: "Pandemic", complexity: 6 } }
      }.not_to change(Game, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /games/new" do
    it "returns 200" do
      get "/games/new"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /games/:id/edit" do
    it "returns 200" do
      game = Game.create!(name: "Carcassonne")
      get "/games/#{game.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /games/:id" do
    it "updates the game and redirects" do
      game = Game.create!(name: "Carcassonne")
      patch "/games/#{game.id}", params: { game: { name: "Carcassonne (Updated)" } }
      expect(game.reload.name).to eq("Carcassonne (Updated)")
      expect(response).to redirect_to(games_path)
    end
  end

  describe "DELETE /games/:id" do
    it "removes the game and redirects" do
      game = Game.create!(name: "Risk")
      expect {
        delete "/games/#{game.id}"
      }.to change(Game, :count).by(-1)
      expect(response).to redirect_to(games_path)
    end
  end

  describe "GET /games" do
    it "returns 200" do
      get "/games"
      expect(response).to have_http_status(:ok)
    end

    it "renders the BGG URL as a link" do
      Game.create!(name: "Catan", bgg_url: "https://boardgamegeek.com/boardgame/13")

      get "/games"

      expect(response.body).to include('href="https://boardgamegeek.com/boardgame/13"')
    end

    it "lists games sorted alphabetically by name" do
      Game.create!(name: "Zendo")
      Game.create!(name: "Agricola")
      Game.create!(name: "Pandemic")

      get "/games"

      expect(response.body).to match(/Agricola.*Pandemic.*Zendo/m)
    end
  end
end
