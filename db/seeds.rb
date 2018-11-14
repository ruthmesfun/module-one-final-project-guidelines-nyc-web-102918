
ruth = User.new
ruth.username = "Darksakura21"
ruth.platform = "pc"
ruth.rank = 5
ruth.save

vibhu = User.new
vibhu.username = "Vibzz00981"
vibhu.platform = "psn"
vibhu.rank = 5
vibhu.save

ninja = User.new
ninja.username = "Ninja"
ninja.platform = "pc"
ninja.rank = 10
ninja.save

ruth.being_recommended_to.create(recommended_id: vibhu.id)
vibhu.being_recommended_to.create(recommended_id: ruth.id)
ruth.being_recommended_to.create(recommended_id: ninja.id)
ninja.being_recommended_to.create(recommended_id: vibhu.id)
