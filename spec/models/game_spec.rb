require "rails_helper"

RSpec.describe Game, type: :model do
  describe ".base_games" do
    it "returns only games with no base_game_id" do
      base = create(:game, name: "Catan")
      create(:game, name: "Catan: Seafarers", base_game_id: base.id)

      expect(Game.base_games).to contain_exactly(base)
    end
  end

  describe ".expansions_only" do
    it "returns only games with a base_game_id" do
      base = create(:game, name: "Catan")
      expansion = create(:game, name: "Catan: Seafarers", base_game_id: base.id)

      expect(Game.expansions_only).to contain_exactly(expansion)
    end
  end

  describe "deleting a base game" do
    it "nullifies base_game_id on expansions rather than deleting them" do
      base = create(:game, name: "Catan")
      expansion = create(:game, name: "Catan: Seafarers", base_game_id: base.id)

      base.destroy

      expect { expansion.reload }.not_to raise_error
      expect(expansion.reload.base_game_id).to be_nil
    end
  end
end
