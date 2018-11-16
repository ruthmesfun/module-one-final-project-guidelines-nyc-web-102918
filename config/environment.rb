require 'bundler'
require 'json'
require 'rest-client'
require 'dotenv'
require 'mailjet'

Bundler.require

Dotenv.load

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger = nil
require_all 'app'

