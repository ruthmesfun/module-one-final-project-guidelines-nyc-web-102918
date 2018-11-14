class RemoveRankFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :rank
  end
end
