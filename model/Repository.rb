require "active_record" 
class Repository < ActiveRecord::Base
  # Table name: repositories
  # Columns:
  #   id (integer, primary key)
  #   repo_id (integer)
  #   repo_name (string)
  #   url (string)
  #   is_private (boolean) 0 for public, 1 for private
  #   is_archived (boolean) 0 for not archived, 1 for archived
  #   created_at (datetime)
  #   updated_at (datetime)
  
  has_many :pull_requests, foreign_key: :repository_id, dependent: :destroy
  
  validates :repo_id, presence: true, uniqueness: true
  validates :repo_name, presence: true
  validates :url, presence: true
end