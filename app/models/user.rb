class User < ActiveRecord::Base
    has_many :being_recommended_to, class_name: "Relationship", 
                                    foreign_key: "recommender_id",
                                    dependent: :destroy

    has_many :receiving_recommendations, class_name: "Relationship",
                                    foreign_key: "recommended_id",
                                    dependent: :destroy

    has_many :recommending, through: :being_recommended, source: :recommended

    has_many :recommenders, through: :receiving_recommendations

    # Match a user
    def match(other_user)
        recommending << other_user
    end

    # Unmatched a user
    def unmatch(other_user)
        recommending.delete(other_user)
    end

    # Returns true if the current user is matched the other user. 

    def matched?(other_user)
        recommending.include?(other_user)
    end

    #grab all the instances of recommenders for the user

    def recommendations 
        recommenders
    end




end