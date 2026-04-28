class AddBaseGameIdToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :base_game_id, :integer
    add_foreign_key :games, :games, column: :base_game_id
  end
end
