require "active_record"

class Review < ActiveRecord::Base
  # Table name: reviews
  # Columns:
  #   id (string, primary key - UUID)
  #   review_id (integer)
  #   pull_request_id (string, foreign key - UUID)
  #   author (string)
  #   state (string)
  #   submitted_at (datetime)
  #   created_at (datetime)
  #   updated_at (datetime)
  
  self.primary_key = 'id'
  
  belongs_to :pull_request
  
  validates :review_id, presence: true, uniqueness: true
  validates :author, presence: true
  validates :state, presence: true
end