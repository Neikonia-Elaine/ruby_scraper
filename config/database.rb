require "active_record"
# Database configuration
# run sqlite3 db/vercel_data.sqlite3 < db/schema.sql to set up the database schema
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "db/vercel_data.sqlite3"
)
