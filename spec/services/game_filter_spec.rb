require "rails_helper"

RSpec.describe GameFilter do
  describe "#results" do
    it "returns all games sorted by name asc when no filters are given" do
      create(:game, name: "Zendo")
      create(:game, name: "Agricola")

      results = GameFilter.new({}).results

      expect(results.map(&:name)).to eq([ "Agricola", "Zendo" ])
    end

    it "sorts by name desc" do
      create(:game, name: "Agricola")
      create(:game, name: "Zendo")

      results = GameFilter.new({ sort: "name", direction: "desc" }).results

      expect(results.map(&:name)).to eq([ "Zendo", "Agricola" ])
    end

    it "sorts by complexity asc" do
      create(:game, name: "Hard",   complexity: 5)
      create(:game, name: "Easy",   complexity: 1)
      create(:game, name: "Medium", complexity: 3)

      results = GameFilter.new({ sort: "complexity", direction: "asc" }).results

      expect(results.map(&:name)).to eq([ "Easy", "Medium", "Hard" ])
    end

    it "sorts by enjoyment desc" do
      create(:game, name: "Loved",   enjoyment: 5)
      create(:game, name: "Disliked", enjoyment: 1)

      results = GameFilter.new({ sort: "enjoyment", direction: "desc" }).results

      expect(results.map(&:name)).to eq([ "Loved", "Disliked" ])
    end

    it "sorts by times_played asc" do
      create(:game, name: "Worn",  times_played: 50)
      create(:game, name: "Fresh", times_played: 1)

      results = GameFilter.new({ sort: "times_played", direction: "asc" }).results

      expect(results.map(&:name)).to eq([ "Fresh", "Worn" ])
    end

    it "filters by condition" do
      mint = create(:game, name: "Mint", condition: :mint)
      create(:game, name: "Poor", condition: :poor)

      results = GameFilter.new({ condition: "mint" }).results

      expect(results).to contain_exactly(mint)
    end

    it "filters by complexity" do
      medium = create(:game, name: "Medium", complexity: 3)
      create(:game, name: "Hard", complexity: 5)

      results = GameFilter.new({ complexity: "3" }).results

      expect(results).to contain_exactly(medium)
    end

    it "filters by enjoyment" do
      loved = create(:game, name: "Loved", enjoyment: 5)
      create(:game, name: "Meh", enjoyment: 2)

      results = GameFilter.new({ enjoyment: "5" }).results

      expect(results).to contain_exactly(loved)
    end

    it "filters by player count: returns games that support N players" do
      solo = create(:game, name: "Solo",  min_players: 1, max_players: 1)
      two_plus = create(:game, name: "Two Plus", min_players: 2, max_players: 6)
      any = create(:game, name: "Any", min_players: 1, max_players: 6)

      results = GameFilter.new({ player_count: "2" }).results

      expect(results).to contain_exactly(two_plus, any)
      expect(results).not_to include(solo)
    end

    it "includes a game when player count equals its min_players boundary" do
      game = create(:game, min_players: 3, max_players: 6)

      results = GameFilter.new({ player_count: "3" }).results

      expect(results).to include(game)
    end

    it "includes a game when player count equals its max_players boundary" do
      game = create(:game, min_players: 1, max_players: 4)

      results = GameFilter.new({ player_count: "4" }).results

      expect(results).to include(game)
    end

    it "filters by max_playtime: returns games whose min_playtime fits within the limit" do
      quick  = create(:game, name: "Quick",  min_playtime: 15,  max_playtime: 30)
      long   = create(:game, name: "Long",   min_playtime: 120, max_playtime: 240)

      results = GameFilter.new({ max_playtime: "60" }).results

      expect(results).to include(quick)
      expect(results).not_to include(long)
    end

    it "includes a game when its min_playtime exactly equals max_playtime param" do
      game = create(:game, min_playtime: 60, max_playtime: 120)

      results = GameFilter.new({ max_playtime: "60" }).results

      expect(results).to include(game)
    end

    it "filters by genre OR mode: returns games matching any selected genre" do
      strategy = create(:genre, name: "Strategy")
      party    = create(:genre, name: "Party")
      alpha    = create(:game, name: "Alpha")
      beta     = create(:game, name: "Beta")
      gamma    = create(:game, name: "Gamma")
      alpha.genres << strategy
      beta.genres  << party

      results = GameFilter.new({ genre_ids: [ strategy.id, party.id ], genre_mode: "or" }).results

      expect(results).to include(alpha, beta)
      expect(results).not_to include(gamma)
    end

    it "filters by genre AND mode: returns only games with all selected genres" do
      strategy = create(:genre, name: "Strategy")
      party    = create(:genre, name: "Party")
      both  = create(:game, name: "Both")
      one   = create(:game, name: "One")
      both.genres << [ strategy, party ]
      one.genres  << strategy

      results = GameFilter.new({ genre_ids: [ strategy.id, party.id ], genre_mode: "and" }).results

      expect(results).to contain_exactly(both)
    end

    it "AND and OR produce different results for the same genre selection" do
      strategy = create(:genre, name: "Strategy")
      party    = create(:genre, name: "Party")
      both  = create(:game, name: "Both")
      one   = create(:game, name: "One")
      both.genres << [ strategy, party ]
      one.genres  << strategy

      or_results  = GameFilter.new({ genre_ids: [ strategy.id, party.id ], genre_mode: "or" }).results
      and_results = GameFilter.new({ genre_ids: [ strategy.id, party.id ], genre_mode: "and" }).results

      expect(or_results.map(&:id)).to include(both.id, one.id)
      expect(and_results.map(&:id)).to contain_exactly(both.id)
    end

    it "returns an empty result set when no games match the filters" do
      create(:game, name: "Only Game", condition: :mint)

      results = GameFilter.new({ condition: "damaged" }).results

      expect(results).to be_empty
    end
  end
end
