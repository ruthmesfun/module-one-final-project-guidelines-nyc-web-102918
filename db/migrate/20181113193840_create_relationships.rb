class CreateRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :relationships do |t|
      t.integer :recommended_id 
      t.integer :recommender_id

      t.timestamps
    end

    add_index :relationships, :recommended_id
    add_index :relationships, :recommender_id
    add_index :relationships, [:recommended_id, :recommender_id], unique:true
  end
end
