class User < ActiveRecord::Base
    has_many :active_relationships, class_name: "Relationship", 
                                    foreign_key: "recommender_id",
                                    dependent: :destroy

end