class User < ActiveRecord::Base
    has_many :being_recommended_to, class_name: "Relationship", 
                                    foreign_key: "recommender_id",
                                    dependent: :destroy

    has_many :receiving_recommendations, class_name: "Relationship",
                                    foreign_key: "recommended_id",
                                    dependent: :destroy

    has_many :recommending, through: :being_recommended_to, source: :recommended

    has_many :recommenders, through: :receiving_recommendations

    
    def player_api_hash

        if platform == "psn"
          user = "psn(#{username})"
        elsif platform == "xbox"
          user= "xbl(#{username})"
        else
            user = username
        end

        response_string = RestClient.get("https://api.fortnitetracker.com/v1/profile/#{platform}/#{user}", headers={"TRN-Api-Key": "ca3bdf7b-93b1-466f-a75b-12086ad5359b"})
        response_hash = JSON.parse(response_string)
    
    end

    # Match a user
    def match(other_user)
        recommending << other_user
    end

    # Unmatched a user
    def unmatch(other_user) #need ot talk to TC on best way to delete. 
        recommending.delete(other_user) #deletes relationship from the other user's table
        # save
        # other_user.recommending.delete(User.find(self)) This is not working!
        # other_user.save
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