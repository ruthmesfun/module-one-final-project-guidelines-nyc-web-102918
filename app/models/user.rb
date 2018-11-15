class User < ActiveRecord::Base
    has_many :stats
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

        response_string = RestClient.get("https://api.fortnitetracker.com/v1/profile/#{platform}/#{user}", headers={"TRN-Api-Key": ENV['API_KEY']})
        response_hash = JSON.parse(response_string)
    end

    # This saves stats in the database once pulled up
    def save_stats
        Stat.create(total_wins: self.total_wins, kill_death_ratio: self.kd_ratio, total_matches: self.total_matches, total_kills: self.total_kills, rank: self.rank, user_id: self.id )
    end

    #Player stats -- should this be moved to Stats then? 
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
      
    def  average_rating
       rating_array = Relationship.where(recommended_id: self.id).select(:rating).map{|match| match.rating}

       avg_rating = rating_array.inject(:+)/ (rating_array.count).to_f

       avg_rating
    end
    # Match a user based on win conditions 

    def recommended?
        average_rating >= 3
    end

    def match(other_user)

        min_wins = total_wins - 15
        max_wins =  total_wins + 15

        if min_wins <= other_user.total_wins && max_wins >= other_user.total_wins

            being_recommended_to.find_or_create_by(recommended_id: other_user.id)

            other_user.being_recommended_to.find_or_create_by(recommended_id: self.id )
        else
            "Please suggest another player."
        end
    end

    def generate_recommendations # grab a list of people who would be recommended to this person
        User.all.each do |user|
            self.match(user)
        end
    end

    def recommendations 
        Relationship.all.select{|relationship| relationship.recommender_id == self.id }
    end

    def select_recommended
        other_user_id = recommendations.sample.recommened_id
        User.find(other_user_id)
    end


    # Unmatched a user
    def unmatch(other_user) 
        Relationship.where("recommended_id= ? AND recommender_id=?", other_user.id, self.id).delete_all

        Relationship.where("recommended_id= ? AND recommender_id=? ", self.id, other_user.id).delete_all
    end


    # Rate the person you played with

    def rate_recommended(other_user, new_rating)
        Relationship.where("recommended_id= ? AND recommender_id=?", other_user.id, self.id).update(rating: new_rating)
    end

    #Email creator method

    def mail_my_stats

        Mailjet.configure do |config|
            config.api_key = ENV['EMAIL']
          
            config.secret_key = ENV['EMAIL_SECRET_KEY']
          
            config.api_version = "v3.1"
          end

          wins = "Total Wins: #{total_wins}"
          tot_matches =  "Total Matches: #{total_matches}"
          tot_kills =  "Total Kills: #{total_kills}"
          kd =  "Kill/Death Ratio: #{kd_ratio}"
          myRank =  "Rank: #{rank}"
        
        variable = Mailjet::Send.create(messages: [{
            'From'=> {
                'Email'=> "vibhu.mahendru@flatironschool.com",
                'Name'=> 'My Fortnite Stats'
            },
            'To'=> [
                {
                    'Email'=> email,
                    'Name'=> username
                }
            ],
            'Subject'=> 'stats',
            'TextPart'=> "LifeTime Stats:
        
            #{wins}
            #{tot_matches}
            #{tot_kills}
            #{kd}
            #{myRank}
            "
        
        }]
        )
        p variable.attributes['Messages']
    end

end