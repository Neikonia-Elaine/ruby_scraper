class RateLimiter
  
  def initialize(client)
    @client = client
  end

  # Check rate limit status
  def check_rate_limit
    rate_limit = @client.rate_limit
    
    {
      remaining: rate_limit.remaining,
      limit: rate_limit.limit,
      resets_at: rate_limit.resets_at,
      resets_in: rate_limit.resets_in
    }
  end

  # Wait if rate limit is low
  def wait_if_needed(threshold: 10)
    rate_limit_info = check_rate_limit
    
    if rate_limit_info[:remaining] <= threshold
      sleep_time = rate_limit_info[:resets_in] + 5 # Add 5 second buffer
      
      puts "\nRate limit low (#{rate_limit_info[:remaining]} requests remaining)"
      puts "Waiting #{sleep_time} seconds until reset at #{rate_limit_info[:resets_at]}..."
      
      sleep(sleep_time)
      puts "✓ Rate limit reset. Continuing..."
    end
  end

  # Execute a block with automatic retry on rate limit errors
  def with_retry(max_retries: 3, &block)
    retries = 0
    
    begin
      wait_if_needed
      block.call
    rescue Octokit::TooManyRequests => e
      # Rate limit exceeded
      if retries < max_retries
        retries += 1
        reset_time = e.response_headers['X-RateLimit-Reset'].to_i
        sleep_time = reset_time - Time.now.to_i + 5
        
        puts "\nRate limit exceeded! (Attempt #{retries}/#{max_retries})"
        puts "Waiting #{sleep_time} seconds..."
        sleep(sleep_time)
        
        retry
      else
        puts "\nMax retries reached. Rate limit still exceeded."
        raise
      end
    rescue Octokit::ServerError, Octokit::Error => e
      # Other GitHub API errors
      if retries < max_retries
        retries += 1
        wait_time = 2 ** retries # Exponential backoff: 2, 4, 8 seconds
        
        puts "\nAPI Error: #{e.message} (Attempt #{retries}/#{max_retries})"
        puts "Retrying in #{wait_time} seconds..."
        sleep(wait_time)
        
        retry
      else
        puts "\nMax retries reached. Error: #{e.message}"
        raise
      end
    end
  end

  # Display current rate limit status
  def display_status
    info = check_rate_limit
    
    puts "\nGitHub API Rate Limit Status"
    puts "\nRemaining: #{info[:remaining]}/#{info[:limit]}"
    puts "\nResets at: #{info[:resets_at]}"
    puts "\nResets in: #{info[:resets_in]} seconds"
  end

end