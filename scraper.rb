require "active_record"
require "dotenv/load"
require_relative "config/database"
require_relative "service/scraper_service"
require_relative "model/repository"
require_relative "model/pullrequest"
require_relative "model/review"

github_token = ENV["GITHUB_TOKEN"]
if github_token.nil? || github_token.empty?
  puts "ERROR: GITHUB_TOKEN environment variable not set"
  exit 1
end

scraper = ScraperService.new(github_token: github_token)
scraper.scrape_full_workflow("vercel")
puts "Scraping completed!"
