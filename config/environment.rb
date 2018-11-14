require 'bundler'
require 'json'
require 'rest-client'
require 'dotenv'

Bundler.require

Dotenv.load

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'app'

