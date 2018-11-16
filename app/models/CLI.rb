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
            puts "Welcome back, #{self.user_name}!"
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
            puts "Welcome, #{self.user_name}!"
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
        puts "....... \n"
        self.user.display_stats
        puts "....... \n"
    end

    def email_my_stats
        puts "Would you like your stats to be emailed to you? (yes/no)"
        confirm = gets.chomp.downcase
        
        if confirm == 'yes' 
            puts "SENDING EMAIL NOW.... \n"
            puts "................ \n"

            user.mail_my_stats
        else 
            puts "No worries!"
        end
    end

    def todays_recommendation
        self.other_user = user.select_recommended
        puts "We recommend #{other_user.username}!"
        puts "................ \n"
        puts "Would you like to email them and see if they can play now? (yes/no)"
        choice = gets.chomp.downcase

        if choice == "yes"
            user.mail_for_match(self.other_user)
            puts "Sending email..."
            sleep(5)

            puts "_______  ___      _______  __   __    _______  _______  __   __  _______ "
            puts "|       ||   |    |   _   ||  | |  |  |       ||   _   ||  |_|  ||       |"
            puts "|    _  ||   |    |  |_|  ||  |_|  |  |    ___||  |_|  ||       ||    ___|"
            puts "|   |_| ||   |    |       ||       |  |   | __ |       ||       ||   |___ "
            puts "|    ___||   |___ |       ||_     _|  |   ||  ||       ||       ||    ___|"
            puts "|   |    |       ||   _   |  |   |    |   |_| ||   _   || ||_|| ||   |___ "
            puts "|___|    |_______||__| |__|  |___|    |_______||__| |__||_|   |_||_______|"
            
            puts "\n"
            puts "\n"
            sleep(4)
            puts " __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __" 
            puts "|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|"
            sleep(3)
            puts " __ __ __ __ __ __ __ __ __" 
            puts "|__|__|__|__|__|__|__|__|__|"
            sleep(2)
            puts " __ __ __ __ __ __ " 
            puts "|__|__|__|__|__|__|"
            sleep(1)
            puts "\n"
            puts "\n"
            puts " _______  _______  __   __  _______    _______  __   __  _______  ______   "
            puts "|       ||   _   ||  |_|  ||       |  |       ||  | |  ||       ||    _ |  "
            puts "|    ___||  |_|  ||       ||    ___|  |   _   ||  |_|  ||    ___||   | ||  "
            puts "|   | __ |       ||       ||   |___   |  | |  ||       ||   |___ |   |_||_ "
            puts "|   ||  ||       ||       ||    ___|  |  |_|  ||       ||    ___||    __  |"
            puts "|   |_| ||   _   || ||_|| ||   |___   |       | |     | |   |___ |   |  | |"
            puts "|_______||__| |__||_|   |_||_______|  |_______|  |___|  |_______||___|  |_|"
            
            sleep(1)
            puts "-----------------------------\n"
            after_game_survey
            puts "Thanks for the Feedback!"
        else
           puts "Thats fine, you can allways come back later!"
        end
    end

    def menu_selection
        if self.choice == "1"
            self.current_stats
            self.email_my_stats
        elsif self.choice == "2"
            todays_recommendation


        elsif self.choice == "3"
            puts "Who would you like to be compared to?"
            other_username = gets.chomp
            compared_stats(other_username)
        end
    end

    def compared_stats(other_user)
        puts "Your stats: \n"
        current_stats

        puts "-----------------------------\n"

        puts "#{other_user}'s stats: \n"

        user.find_users_stats(other_user)
    end

    def after_game_survey
        puts "How did you like playing with #{other_user.username}? Rate them on a scale 1 - 5."
        rate = gets.chomp.to_i 
        puts "-----------------------------\n"
        user.rate_a_player(other_user, rate)

        if  rate < 3 then user.unmatch(other_user) end
    end

    def self.start
        cli1 = CLI.new

        cli1.greeting

        cli1.get_username

        cli1.identifier

        choice = "yes"

        until choice == "no"
            cli1.menu

            cli1.menu_selection

            puts "You would like to go to the menu (yes/no)?"
            choice = gets.chomp
        end

        puts "Thanks for using the app and come again!"
    end

end

