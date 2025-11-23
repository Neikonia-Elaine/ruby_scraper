require "active_record"

class PullRequest < ActiveRecord::Base
  # Table name: pull_requests
  # Columns:
  #   id (string, primary key - UUID)
  #   pr_id (integer)
  #   repository_id (string, foreign key - UUID)
  #   number (integer)
  #   title (string)
  #   updated_at (datetime)
  #   closed_at (datetime)
  #   merged_at (datetime)
  #   author (string)
  #   additions (integer)
  #   deletions (integer)
  #   changed_files (integer)
  #   commits_count (integer)
  #   created_at (datetime)
  
  self.primary_key = 'id'
  
  belongs_to :repository
  has_many :reviews, foreign_key: :pull_request_id, dependent: :destroy
  
  validates :pr_id, presence: true, uniqueness: true
  validates :number, presence: true
  validates :author, presence: true
end