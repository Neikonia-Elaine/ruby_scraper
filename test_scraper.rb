require "active_record"
require "dotenv/load"
require "json"
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

# Scrape only the first repo
puts "Fetching first repository..."
repos = scraper.instance_variable_get(:@client).org_repos("vercel", type: "public", per_page: 1)
first_repo = repos.first

if first_repo
  puts "\nFIRST REPOSITORY (JSON)"
  puts JSON.pretty_generate(first_repo.to_h)
  
  # Scrape first PR from first repo
  repo_name = first_repo[:name]
  puts "\n\nFetching first PR from #{repo_name}..."
  prs = scraper.instance_variable_get(:@client).pull_requests("vercel/#{repo_name}", state: "all", per_page: 1)
  first_pr = prs.first
  
  if first_pr
    # Get detailed PR info
    detailed_pr = scraper.instance_variable_get(:@client).pull_request("vercel/#{repo_name}", first_pr[:number])
    
    puts "\n=== FIRST PULL REQUEST (JSON) ==="
    puts JSON.pretty_generate(detailed_pr.to_h)
    
    # Scrape first review from first PR
    puts "\n\nFetching first review from PR ##{first_pr[:number]}..."
    reviews = scraper.instance_variable_get(:@client).pull_request_reviews("vercel/#{repo_name}", first_pr[:number])
    first_review = reviews.first
    
    if first_review
      puts "\n=== FIRST REVIEW (JSON) ==="
      puts JSON.pretty_generate(first_review.to_h)
    else
      puts "\nNo reviews found for this PR"
    end
  else
    puts "\nNo PRs found for this repo"
  end
else
  puts "\nNo repositories found"
end

puts "\n\nTest scraping completed!"