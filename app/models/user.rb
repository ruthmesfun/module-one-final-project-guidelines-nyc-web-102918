class User < ActiveRecord::Base
    has_many :active_relationships, class_name: "Relationship", 
                                    foreign_key: "recommender_id",
                                    dependent: :destroy

    
    has_many :recommending, through: :active_relationships, source: :recommended



end