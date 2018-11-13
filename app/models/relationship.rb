class Relationship < ActiveRecord::Base
    belongs_to :recommender, class_name: "User"
    belongs_to :recommended, class_name: "User"

    #  I need to initialize the ratins in a relationship

end