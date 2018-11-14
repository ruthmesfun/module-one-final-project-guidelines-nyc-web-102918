class Relationship < ActiveRecord::Base
    belongs_to :recommender, class_name: "User"
    belongs_to :recommended, class_name: "User"
end