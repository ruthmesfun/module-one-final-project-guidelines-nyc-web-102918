class AddRatingToRelationships < ActiveRecord::Migration[5.0]
  def change
    add_column :relationships, :rating, :integer
  end
end
