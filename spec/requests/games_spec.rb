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

    it "renders the add-genre form in the game form" do
      get "/games/new"

      expect(response.body).to include('name="genre[name]"')
      expect(response.body).to include('name="context"')
    end

    it "renders a delete button next to each genre in the game form" do
      create(:genre, name: "Strategy")

      get "/games/new"

      expect(response.body).to include("Delete Strategy")
    end
  end

  describe "GET /games/:id/edit" do
    it "returns 200" do
      game = create(:game, name: "Carcassonne")
      get "/games/#{game.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /games/:id" do
    it "updates the game and redirects" do
      game = create(:game, name: "Carcassonne")
      patch "/games/#{game.id}", params: { game: { name: "Carcassonne (Updated)" } }
      expect(game.reload.name).to eq("Carcassonne (Updated)")
      expect(response).to redirect_to(games_path)
    end
  end

  describe "DELETE /games/:id" do
    it "removes the game and redirects" do
      game = create(:game, name: "Risk")
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
      create(:game, name: "Catan", bgg_url: "https://boardgamegeek.com/boardgame/13")

      get "/games"

      expect(response.body).to include('href="https://boardgamegeek.com/boardgame/13"')
    end

    it "lists games sorted alphabetically by name" do
      create(:game, name: "Zendo")
      create(:game, name: "Agricola")
      create(:game, name: "Pandemic")

      get "/games"

      expect(response.body).to match(/Agricola.*Pandemic.*Zendo/m)
    end

    it "sorts by complexity ascending when sort=complexity&direction=asc" do
      create(:game, name: "Alpha", complexity: 3)
      create(:game, name: "Beta", complexity: 1)
      create(:game, name: "Gamma", complexity: 5)

      get "/games", params: { sort: "complexity", direction: "asc" }

      expect(response.body).to match(/Beta.*Alpha.*Gamma/m)
    end

    it "sorts by name descending when sort=name&direction=desc" do
      create(:game, name: "Agricola")
      create(:game, name: "Zendo")

      get "/games", params: { sort: "name", direction: "desc" }

      expect(response.body).to match(/Zendo.*Agricola/m)
    end

    it "sorts by times_played ascending when sort=times_played" do
      create(:game, name: "Alpha", times_played: 10)
      create(:game, name: "Beta", times_played: 2)

      get "/games", params: { sort: "times_played", direction: "asc" }

      expect(response.body).to match(/Beta.*Alpha/m)
    end

    it "sorts by enjoyment descending when sort=enjoyment&direction=desc" do
      create(:game, name: "Alpha", enjoyment: 2)
      create(:game, name: "Beta", enjoyment: 5)

      get "/games", params: { sort: "enjoyment", direction: "desc" }

      expect(response.body).to match(/Beta.*Alpha/m)
    end

    it "filters by condition" do
      create(:game, name: "Mint Game", condition: :mint)
      create(:game, name: "Poor Game", condition: :poor)

      get "/games", params: { condition: "mint" }

      expect(response.body).to include("Mint Game")
      expect(response.body).not_to include("Poor Game")
    end

    it "filters by genre (OR mode): returns games matching any selected genre" do
      strategy = create(:genre, name: "Strategy")
      party    = create(:genre, name: "Party")
      alpha    = create(:game, name: "Alpha")
      beta     = create(:game, name: "Beta")
      gamma    = create(:game, name: "Gamma")
      alpha.genres << strategy
      beta.genres  << party

      get "/games", params: { genre_ids: [ strategy.id, party.id ], genre_mode: "or" }

      expect(response.body).to include("Alpha")
      expect(response.body).to include("Beta")
      expect(response.body).not_to include("Gamma")
    end

    it "filters by genre (AND mode): returns only games matching all selected genres" do
      strategy = create(:genre, name: "Strategy")
      party    = create(:genre, name: "Party")
      alpha    = create(:game, name: "Alpha")
      beta     = create(:game, name: "Beta")
      alpha.genres << [ strategy, party ]
      beta.genres  << strategy

      get "/games", params: { genre_ids: [ strategy.id, party.id ], genre_mode: "and" }

      expect(response.body).to include("Alpha")
      expect(response.body).not_to include("Beta")
    end

    it "filters by player count: returns games that support N players" do
      create(:game, name: "Solo Only",  min_players: 1, max_players: 1)
      create(:game, name: "Two Plus",   min_players: 2, max_players: 6)
      create(:game, name: "Any Count",  min_players: 1, max_players: 6)

      get "/games", params: { player_count: 2 }

      expect(response.body).to include("Two Plus")
      expect(response.body).to include("Any Count")
      expect(response.body).not_to include("Solo Only")
    end

    it "filters by playtime range: returns games playable within the given minutes" do
      create(:game, name: "Quick",  min_playtime: 15,  max_playtime: 30)
      create(:game, name: "Long",   min_playtime: 120, max_playtime: 240)
      create(:game, name: "Medium", min_playtime: 45,  max_playtime: 90)

      get "/games", params: { max_playtime: 60 }

      expect(response.body).to include("Quick")
      expect(response.body).to include("Medium")
      expect(response.body).not_to include("Long")
    end

    it "filters by complexity" do
      create(:game, name: "Easy",   complexity: 1)
      create(:game, name: "Medium", complexity: 3)
      create(:game, name: "Hard",   complexity: 5)

      get "/games", params: { complexity: 3 }

      expect(response.body).to include("Medium")
      expect(response.body).not_to include("Easy")
      expect(response.body).not_to include("Hard")
    end

    it "filters by enjoyment" do
      create(:game, name: "Loved",  enjoyment: 5)
      create(:game, name: "Meh",    enjoyment: 2)

      get "/games", params: { enjoyment: 5 }

      expect(response.body).to include("Loved")
      expect(response.body).not_to include("Meh")
    end

    it "renders sortable links for name, complexity, enjoyment, and times_played columns" do
      create(:game)

      get "/games"

      expect(response.body).to include('sort=name')
      expect(response.body).to include('sort=complexity')
      expect(response.body).to include('sort=enjoyment')
      expect(response.body).to include('sort=times_played')
    end

    it "flips direction to desc when already sorted asc by that column" do
      create(:game)

      get "/games", params: { sort: "name", direction: "asc" }

      expect(response.body).to include('sort=name&amp;direction=desc').or(include('direction=desc&amp;sort=name'))
    end

    it "renders the filter panel with genre checkboxes and AND/OR toggle" do
      create(:genre, name: "Strategy")
      create(:genre, name: "Party")

      get "/games"

      expect(response.body).to include("Strategy")
      expect(response.body).to include("Party")
      expect(response.body).to include('name="genre_mode"').or(include('genre_mode'))
    end

    it "persists filter params in the URL on form submit" do
      genre = create(:genre, name: "Strategy")
      create(:game, name: "Chess").genres << genre

      get "/games", params: { genre_ids: [ genre.id ], genre_mode: "or" }

      expect(response.body).to include("Chess")
    end

    it "returns all games when no filters are applied" do
      create(:game, name: "Alpha")
      create(:game, name: "Beta")

      get "/games"

      expect(response.body).to include("Alpha")
      expect(response.body).to include("Beta")
    end

    it "renders the add-genre form in the filter panel" do
      get "/games"

      expect(response.body).to include('action="/genres"')
      expect(response.body).to include('name="genre[name]"')
    end

    it "renders a delete button next to each genre in the filter panel" do
      create(:genre, name: "Strategy")

      get "/games"

      expect(response.body).to include("Delete Strategy")
    end
  end
end
