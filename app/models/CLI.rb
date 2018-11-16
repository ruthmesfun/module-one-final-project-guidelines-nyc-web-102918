class CLI
    attr_accessor :user_name, :e_mail, :platform, :choice, :user, :other_user

    def greeting
        puts "Welcome to your Fortnite Stats & Recommendation App."
        puts "Lookup your current stats and let us recommend a player you would team well with."
    end

    def get_username
        puts "Please enter your username:"
        self.user_name = gets.chomp
        self.user_name
    end

    def identifier  #identifer will give us the instance of the User
        if User.find_by(username: self.user_name)

            puts "PROCESSING YOUR DATA.... \n"
            puts "............... \n"
            self.user = User.find_by(username: self.user_name)
            self.user.save_stats
            self.user.generate_recommendations
            puts "....... \n"
        else
            puts "Oh looks like you are not in our database. Welcome! What is your email?"
            self.e_mail = gets.chomp

            puts "Which platform do you use? (pc, psn, xbl [xbox])"
                self.platform = gets.chomp
            

            puts "PROCESSING YOUR DATA.... \n"
            puts "................ \n"
            self.user = User.find_or_create_by(username: self.user_name, email: self.e_mail, platform: self.platform)
            self.user.save_stats
            self.user.generate_recommendations
            puts "............ \n"
            puts "....... \n"
            puts "\n"
        end
        user
    end

    def menu
        puts "MENU \n"

        puts "-----------------------------\n"

        puts "Choose one of the following:"
        puts "1. View my current stats"
        puts "2. Recommend me a player"
        puts "3. Compare your stats with another player"

        self.choice = gets.chomp
         
    end

    def current_stats
        self.user.display_stats
        #Option for email!
    end

    def todays_recommendation
        self.other_user = user.select_recommended
        puts "We recommend #{other_user.username}!"
        #Option for email! 
    end

    def menu_selection
        if self.choice == "1"
            self.current_stats
        elsif self.choice == "2"
            todays_recommendation
        elsif self.choice == "3"
            puts "Who would you like to be compared to?"
            other_username = gets.chomp
            compared_stats(other_username)
        end
    end

    def compared_stats(other_username)
        puts "Your stats: \n"
        current_stats

        puts "-----------------------------\n"

        puts "#{other_username}'s stats: \n"

        user.find_users_stats(other_username)
    end


end

# 3. Email me my stats
# Email them directly their stats 
# 4. Recommend me a player to play with
# We think you would have a great time with this player:
# Username
# Would you like us to email them? 
# YES [ Email]
# PLAY TIME!!!! [ANIMATION]e

# GAME OVER 
# How did you enjoy your time with [other user] (rate: 1-5)
# Rating 
# Increase their avg or decrease 
# It would change their suggestions
# NO => No problem thought to ask! 
