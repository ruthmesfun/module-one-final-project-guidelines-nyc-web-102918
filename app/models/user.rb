class User < ActiveRecord::Base
    has_many :being_recommended_to, class_name: "Relationship", 
                                    foreign_key: "recommender_id",
                                    dependent: :destroy

    has_many :receiving_recommendations, class_name: "Relationship",
                                    foreign_key: "recommended_id",
                                    dependent: :destroy

    has_many :recommending, through: :being_recommended_to, source: :recommended

    has_many :recommenders, through: :receiving_recommendations

    # DATA - API HASH 
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

    #Player stats
    def lifeTimeStats
         player_api_hash["lifeTimeStats"]
    end
    
    def total_wins
        lifeTimeStats[8]["value"].to_i #[8] is the 8th element in lifeTimeStats array which contains total wins.
    end

    def total_matches
        lifeTimeStats[7]["value"].to_i #[7] is the 7th element in lifeTimeStats array which contains total matches.
      end
    
      def total_kills
        lifeTimeStats[10]["value"].to_i #[10] is the 10th element in lifeTimeStats array which contains total kills.
      end
    
      def kd_ratio
        lifeTimeStats[11]["value"].to_f #[11] is the 11th element in lifeTimeStats array which contains Kill/Death ratio.
      end
    
      def rank
        player_api_hash["stats"]["p2"]["trnRating"]["rank"]
      end
    
      def display_stats
        puts "Total Wins: #{total_wins}"
        puts "Total Matches: #{total_matches}"
        puts "Total Kills: #{total_kills}"
        puts "Kill/Death Ratio: #{kd_ratio}"
        puts "Rank: #{rank}"
      end

    # Match a user
    def match(other_user)

        being_recommended_to.find_or_create_by(recommended_id: other_user.id)

        other_user.being_recommended_to.find_or_create_by(recommended_id: self.id )

    end

    # Unmatched a user
    def unmatch(other_user) 
        Relationship.where("recommended_id= ? AND recommender_id=?", other_user.id, self.id).delete_all

        Relationship.where("recommended_id= ? AND recommender_id=? ", self.id, other_user.id).delete_all
    end

    #grab all the instances of matches for the user

    def matches 
        recommenders
    end




end