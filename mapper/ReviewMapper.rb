require "securerandom"

class ReviewMapper
  def self.from_api(api_review, pull_request_id)
    ::Review.new(
      id: SecureRandom.uuid,
      review_id: api_review["id"],
      pull_request_id: pull_request_id,
      author: api_review["user"]["login"],
      state: api_review["state"],
      submitted_at: api_review["submitted_at"]
    )
  end
end