class RepositoryMapper
  def self.from_api(api_repo)
    Repository.new(
      repo_id: api_repo["id"],
      repo_name: api_repo["name"],
      url: api_repo["html_url"],
      is_private: api_repo["private"],
      is_archived: api_repo["archived"]
    )
  end
end