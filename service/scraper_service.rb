require_relative "../service/db_service"
require_relative "../lib/rate_limit"
require "octokit"

class ScraperService
  
  def initialize(github_token: nil)
    @db_service = DBService.new
    @client = Octokit::Client.new(access_token: github_token)
    @rate_limiter = RateLimiter.new(@client)
  end

  # Scrape all public repositories for an organization
  # @param org_name [String] GitHub organization name
  def scrape_org_repos(org_name)
    puts "Fetching repositories for organization: #{org_name}..."
    
    # Display rate limit status at start
    @rate_limiter.display_status
    
    all_repos = []
    page = 1
    
    loop do
      puts "  Fetching page #{page}..."
      
      repos_page = @rate_limiter.with_retry do
        @client.org_repos(org_name, type: "public", per_page: 100, page: page)
      end
      
      break if repos_page.empty?
      
      all_repos += repos_page
      puts "  Retrieved #{repos_page.size} repositories (total: #{all_repos.size})"
      
      page += 1
    end
    
    puts "Found #{all_repos.size} public repositories in total. Saving to database..."
    @db_service.add_all_public_repo(all_repos)
    
    puts "✓ #{all_repos.size} repositories saved successfully"
    all_repos
  rescue Octokit::Error => e
    puts "GitHub API Error: #{e.message}"
    raise
  end

  # Scrape pull requests for a specific repository
  # @param owner [String] Repository owner
  # @param repo_name [String] Repository name
  def scrape_repo_pull_requests(owner, repo_name)
    puts "\n  Fetching pull requests for #{owner}/#{repo_name}..."
    
    # Find repository record in database
    repo_record = Repository.find_by(repo_name: repo_name)
    unless repo_record
      puts "Repository not found in database. Skipping..."
      return []
    end
    
    # Get list of PRs (lightweight data)
    pr_list = @rate_limiter.with_retry do
      @client.pull_requests("#{owner}/#{repo_name}", state: "all")
    end
    
    if pr_list.empty?
      puts "  No pull requests found."
      return []
    end
    
    puts "  Found #{pr_list.size} pull requests. Fetching detailed info..."
    
    # Get detailed info for each PR
    detailed_prs = []
    failed_prs = []
    
    pr_list.each_with_index do |pr, index|
      print "Progress: #{index + 1}/#{pr_list.size}\r"
      
      begin
        # Fetch full PR details with additions, deletions, etc.
        detailed_pr = @rate_limiter.with_retry do
          @client.pull_request("#{owner}/#{repo_name}", pr[:number])
        end
        detailed_prs << detailed_pr
        
        sleep(0.1)  # Small delay to avoid hitting rate limits
      rescue => e
        puts "\nFailed to fetch PR ##{pr[:number]}: #{e.message}"
        failed_prs << pr[:number]
      end
    end
    
    puts "\nSaving #{detailed_prs.size} pull requests to database..."
    @db_service.add_pr_for_repo(repo_record, detailed_prs) unless detailed_prs.empty?
    
    puts "\n#{detailed_prs.size} pull requests saved"
    puts "\n#{failed_prs.size} pull requests failed: #{failed_prs.join(', ')}" if failed_prs.any?
    
    detailed_prs
  rescue Octokit::Error => e
    puts "  GitHub API Error: #{e.message}"
    []
  end

  # Scrape reviews for a specific pull request
  # @param owner [String] Repository owner
  # @param repo_name [String] Repository name
  # @param pr_number [Integer] Pull request number
  def scrape_pr_reviews(owner, repo_name, pr_number)
    # Find PR record in database
    repo = Repository.find_by(repo_name: repo_name)
    return [] unless repo
    
    pr_record = PullRequest.find_by(repository_id: repo.id, number: pr_number)
    unless pr_record
      return []
    end
    
    # Fetch reviews from GitHub API with retry
    reviews = @rate_limiter.with_retry do
      @client.pull_request_reviews("#{owner}/#{repo_name}", pr_number)
    end
    
    return [] if reviews.empty?
    
    @db_service.add_reviews_for_pr(pr_record, reviews)
    reviews
  rescue Octokit::Error => e
    puts "Error fetching reviews for PR ##{pr_number}: #{e.message}"
    []
  end

  # Full scrape workflow for Vercel organization
  # @param org_name [String] Organization name (default: "vercel")
  def scrape_full_workflow(org_name = "vercel")
    puts "\n" + "="*60
    puts "Starting full scrape for organization: #{org_name}"
    puts "="*60 + "\n"
    
    # Scrape all public repositories
    repos = scrape_org_repos(org_name)
    
    return if repos.empty?
    
    # For each repo, scrape PRs and reviews
    repos.each_with_index do |repo_data, index|
      repo_name = repo_data[:name]
      
      puts "\n[#{index + 1}/#{repos.size}] Processing repository: #{repo_name}"
      
      # Scrape pull requests
      prs = scrape_repo_pull_requests(org_name, repo_name)
      
      next if prs.empty?
      
      # Scrape reviews for each PR
      repo_record = Repository.find_by(repo_name: repo_name)
      pull_requests = PullRequest.where(repository_id: repo_record.id)
      
      puts "  Fetching reviews for #{pull_requests.count} pull requests..."
      
      pull_requests.each_with_index do |pr, pr_index|
        print "Progress: #{pr_index + 1}/#{pull_requests.count}\r"
        scrape_pr_reviews(org_name, repo_name, pr.number)
      end
      
      puts "✓ Reviews scraped for all PRs"
    end
    
    # Print summary
    print_summary
  end

  private

  def print_summary
    puts "Scraping Summary"
    puts "Total Repositories: #{Repository.count}"
    puts "Total Pull Requests: #{PullRequest.count}"
    puts "Total Reviews: #{Review.count}"
  end

end