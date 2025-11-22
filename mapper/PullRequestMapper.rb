class PullRequestMapper
  def self.from_api(api_pr, repository_id)
    PullRequest.new(
      pr_id: api_pr["id"],
      repository_id: repository_id,
      number: api_pr["number"],
      title: api_pr["title"],
      updated_at: api_pr["updated_at"],
      closed_at: api_pr["closed_at"],
      merged_at: api_pr["merged_at"],
      author: api_pr["user"]["login"],
      additions: api_pr["additions"],
      deletions: api_pr["deletions"],
      changed_files: api_pr["changed_files"],
      commits_count: api_pr["commits"]
    )
  end
end