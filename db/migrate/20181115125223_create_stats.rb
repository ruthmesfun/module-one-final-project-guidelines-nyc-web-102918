class CreateStats < ActiveRecord::Migration[5.0]
  def change
    create_table :stats do |t|
      t.integer :total_wins
      t.integer :total_matches
      t.float :kill_death_ratio
      t.integer :total_kills
      t.integer :rank
      t.integer :user_id
      
      t.timestamps
    end
  end
end


