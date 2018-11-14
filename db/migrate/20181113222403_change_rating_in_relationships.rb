class ChangeRatingInRelationships < ActiveRecord::Migration[5.0]
  def change
    change_column :relationships, :rating, :integer, :default => 5, :null => false # default the rating to 5
  end
end

