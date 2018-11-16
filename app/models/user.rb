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

    #Player stats -- should this be moved to Stats then? 
    def lifeTimeStats
        player_api_hash["lifeTimeStats"]
   end

    # This saves stats in the database once pulled up
    def save_stats
        Stat.create(total_wins: lifeTimeStats[8]["value"].to_i, kill_death_ratio: lifeTimeStats[11]["value"].to_f, total_matches:  lifeTimeStats[7]["value"].to_i, total_kills: lifeTimeStats[10]["value"].to_i, rank: player_api_hash["stats"]["p2"]["trnRating"]["rank"], user_id: self.id)
    end

    def total_wins
        Stat.current_total_wins(self)
    end

    def total_matches
       Stat.current_total_matches(self)
    end
    
    def total_kills
        Stat.current_total_kills(self)
    end
    
    def kd_ratio
        Stat.current_kd_ratio(self)
    end
    
    def rank
        Stat.current_rank(self)
    end
    
    def display_stats
        puts "Total Wins: #{total_wins}"
        puts "Total Matches: #{total_matches}"
        puts "Total Kills: #{total_kills}"
        puts "Kill/Death Ratio: #{kd_ratio}"
        puts "Rank: #{rank}"
    end

    def find_users_stats(other_username)
       other_user = User.find_by(username: other_username)
       other_user.display_stats
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

    def expert_player? #This will match any expert player together
        total_wins > 500
    end

    def match(other_user)

        min_wins = self.total_wins - 15
        max_wins =  self.total_wins + 15

        unless other_user == self
            if self.expert_player? && other_user.expert_player? 
                being_recommended_to.find_or_create_by(recommended_id: other_user.id)
                other_user.being_recommended_to.find_or_create_by(recommended_id: self.id)
            elsif min_wins <= other_user.total_wins && max_wins >= other_user.total_wins
                being_recommended_to.find_or_create_by(recommended_id: other_user.id)
                other_user.being_recommended_to.find_or_create_by(recommended_id: self.id)  
            end
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
        other_user_id = recommendations.sample.recommended_id
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

    # EMAILERS


    # Email stat method 
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

    #Email sent to recommendation 
    def mail_for_match(recommender)
        Mailjet.configure do |config|
          config.api_key = ENV['EMAIL']
      
          config.secret_key = ENV['EMAIL_SECRET_KEY']
      
          config.api_version = "v3.1"
        end
      
      variable = Mailjet::Send.create(messages: [{
          'From'=> {
              'Email'=> "vibhu.mahendru@flatironschool.com",
              'Name'=> "#{self.username}"
          },
          'To'=> [
              {
                  'Email'=> match_email,
                  'Name'=> "#{recommender.email}"
              }
          ],
          'Subject'=> 'New Fortnite Match!',
          'TextPart'=> "Hi #{recommender.username}!
      
      You just matched with #{self.username} on Fortninte!
      Reply 'YES' to play with them."
      
      }]
      )
      p variable.attributes['Messages']
    end


end