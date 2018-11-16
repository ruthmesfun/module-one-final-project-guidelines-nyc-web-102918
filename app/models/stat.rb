class Stat < ActiveRecord::Base
    belongs_to :user


    def self.user_stat(user)
        all.select{|stat| stat.user_id == user.id}
    end

    def self.current_stat(user)
        user_stat(user).last 
    end 

    def self.yesetrdays_stat(user)
        total_num_stats = user_stat(user).count
        user_stat(user)[total_num_stats-2]
    end

    def self.current_total_wins(user)
        self.current_stat(user).total_wins
    end

    def self.current_total_matches(user)
        self.current_stat(user).total_matches
    end
    
    def self.current_total_kills(user)
        self.current_stat(user).total_kills
    end
    
    def self.current_kd_ratio(user)
        self.current_stat(user).kill_death_ratio
    end
    
    def self.current_rank(user)
        self.current_stat(user).rank
    end

    def self.yesterdays_total_wins(user)
        yesetrdays_stat(user).total_wins
    end

    def self.yesterdays_total_matches(user)
        yesetrdays_stat(user).total_matches
    end
    
    def self.yesterdays_total_kills(user)
        yesetrdays_stat(user).total_kills
    end
    
    def self.yesterdays_kd_ratio(user)
        yesetrdays_stat(user).kd_ratio
    end
    
    def self.yesterdays_rank(user)
        yesetrdays_stat(user).rank
    end


end