class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :name
      t.integer :min_players
      t.integer :max_players
      t.text :description
      t.integer :times_played, default: 0, null: false
      t.string :bgg_url
      t.integer :condition
      t.integer :complexity
      t.integer :min_playtime
      t.integer :max_playtime
      t.integer :enjoyment

      t.timestamps
    end
  end
end
