require "active_record" 

class Repository < ActiveRecord::Base
  # Table name: repositories
  # Columns:
  #   id (string, primary key - UUID)
  #   repo_id (integer)
  #   repo_name (string)
  #   url (string)
  #   is_private (boolean)
  #   is_archived (boolean)
  #   created_at (datetime)
  #   updated_at (datetime)
  
  self.primary_key = 'id'
  
  has_many :pull_requests, foreign_key: :repository_id, dependent: :destroy
  
  validates :repo_id, presence: true, uniqueness: true
  validates :repo_name, presence: true
  validates :url, presence: true
end