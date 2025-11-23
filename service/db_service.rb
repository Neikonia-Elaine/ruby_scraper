require "activerecord-import"
require_relative "../model/repository"
require_relative "../model/pullrequest"
require_relative "../model/review"
require_relative "../mapper/repositorymapper"
require_relative "../mapper/pullrequestmapper"
require_relative "../mapper/reviewmapper"

class DBService

  # Batch insert all public repositories using activerecord-import
  # @param repo_data_list [Array] Array of API repo data from GitHub
  def add_all_public_repo(repo_data_list, validate: false)
    return if repo_data_list.empty?
    
    repos = repo_data_list.map { |data| RepositoryMapper.from_api(data) }
    
    Repository.transaction do
      Repository.import(repos, validate: validate)
    end
  rescue StandardError => e
    puts "ERROR: Failed to insert repositories: #{e.message}"
    raise
  end

  # Batch insert pull requests for a repository
  # @param repo_record [Repository] The repository ActiveRecord object
  # @param pr_data_list [Array] Array of API PR data from GitHub
  def add_pr_for_repo(repo_record, pr_data_list, validate: false)
    return if pr_data_list.empty?
    
    prs = pr_data_list.map do |data|
      PullRequestMapper.from_api(data, repo_record.id)
    end
    
    PullRequest.transaction do
      PullRequest.import(prs, validate: validate)
    end
  rescue StandardError => e
    puts "ERROR: Failed to insert pull requests: #{e.message}"
    raise
  end

  # Batch insert reviews for a pull request
  # @param pr_record [PullRequest] The pull request ActiveRecord object
  # @param review_data_list [Array] Array of API review data from GitHub
  def add_reviews_for_pr(pr_record, review_data_list, validate: false)
    return if review_data_list.empty?
    
    reviews = review_data_list.map do |data|
      ReviewMapper.from_api(data, pr_record.id)
    end
    
    Review.transaction do
      Review.import(reviews, validate: validate)
    end
  rescue StandardError => e
    puts "ERROR: Failed to insert reviews: #{e.message}"
    raise
  end

end