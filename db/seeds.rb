
ruth = User.new
ruth.username = "Darksakura21"
ruth.platform = "pc"
ruth.rank = 5
ruth.save

vibhu = User.new
vibhu.username = "vibzz00981"
vibhu.platform = "psn"
vibhu.rank = 5
vibhu.save

ninja = User.new
ninja.username = "Ninja"
ninja.platform = "pc"
ninja.rank = 10
ninja.save

ruth.active_relationships.create(recommended_id: vibhu.id)
ruth.active_relationships.create(recommended_id: ninja.id)
ninja.active_relationships.create(recommended_id: vibhu.id)
