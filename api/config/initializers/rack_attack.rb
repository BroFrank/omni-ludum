# Rack::Attack configuration for rate limiting
# Protects against brute force attacks and DoS

# Define the configuration class
class Rack::Attack::Config
  def self.configure
    # Enable/disable Rack::Attack
    enabled = Rails.application.credentials.dig(:rack_attack, :enabled)
    Rack::Attack.enabled = enabled.nil? ? Rails.env.production? : enabled

    # Safe list - never throttle health check endpoint
    Rack::Attack.safelist("health check") do |req|
      req.path == "/up"
    end

    # Allowlist for internal IPs (if configured)
    Rack::Attack.safelist("internal IPs") do |req|
      internal_ips = Rails.application.credentials.dig(:rack_attack, :allowlist_ips)
      internal_ips&.include?(req.ip)
    end

    # ============================================
    # Authentication Endpoints
    # ============================================

    # Login endpoint - brute force protection (by IP)
    # Limit: 5 requests per minute
    Rack::Attack.throttle("logins/ip", limit: 5, period: 1.minute) do |req|
      if req.path == "/api/v1/auth/login" && req.post?
        req.ip
      end
    end

    # Login endpoint - brute force protection (by email)
    # Limit: 3 requests per minute per email
    Rack::Attack.throttle("logins/email", limit: 3, period: 1.minute) do |req|
      if req.path == "/api/v1/auth/login" && req.post?
        req.params.dig("email")&.to_s&.downcase
      end
    end

    # Refresh token endpoint (by IP)
    # Limit: 30 requests per minute
    Rack::Attack.throttle("refresh/ip", limit: 30, period: 1.minute) do |req|
      if req.path == "/api/v1/auth/refresh" && req.post?
        req.ip
      end
    end

    # Logout endpoint (by IP)
    # Limit: 10 requests per minute
    Rack::Attack.throttle("logout/ip", limit: 10, period: 1.minute) do |req|
      if req.path == "/api/v1/auth/logout" && req.delete?
        req.ip
      end
    end

    # Logout all endpoint (by IP)
    # Limit: 5 requests per minute
    Rack::Attack.throttle("logout_all/ip", limit: 5, period: 1.minute) do |req|
      if req.path == "/api/v1/auth/logout_all" && req.delete?
        req.ip
      end
    end

    # ============================================
    # User Registration
    # ============================================

    # User creation (by IP)
    # Limit: 3 requests per hour
    Rack::Attack.throttle("users/ip", limit: 3, period: 1.hour) do |req|
      if req.path == "/api/v1/users" && req.post?
        req.ip
      end
    end

    # User creation (by email)
    # Limit: 1 request per hour per email
    Rack::Attack.throttle("users/email", limit: 1, period: 1.hour) do |req|
      if req.path == "/api/v1/users" && req.post?
        req.params.dig("user", "email")&.to_s&.downcase
      end
    end

    # ============================================
    # Asset Upload Endpoints
    # ============================================

    # Asset upload (by IP)
    # Limit: 10 requests per minute
    Rack::Attack.throttle("assets/ip", limit: 10, period: 1.minute) do |req|
      if req.path.start_with?("/api/v1/assets") && req.post?
        req.ip
      end
    end

    # Asset upload (by authenticated user)
    # Limit: 20 requests per minute
    Rack::Attack.throttle("assets/user", limit: 20, period: 1.minute) do |req|
      if req.path.start_with?("/api/v1/assets") && req.post?
        # Extract user_id from JWT token if present
        token = req.env["HTTP_AUTHORIZATION"]&.split(" ")&.last
        if token
          begin
            decoded = JWT.decode(token, JWT_SECRET_KEY, false)
            decoded.first&.dig("sub")&.to_s
          rescue JWT::DecodeError
            nil
          end
        end
      end
    end

    # ============================================
    # General API Endpoints
    # ============================================

    # GET requests (by IP)
    # Limit: 300 requests per minute
    Rack::Attack.throttle("api_get/ip", limit: 300, period: 1.minute) do |req|
      req.get? ? req.ip : nil
    end

    # POST/PUT/PATCH requests (by IP)
    # Limit: 60 requests per minute
    Rack::Attack.throttle("api_write/ip", limit: 60, period: 1.minute) do |req|
      if %w[post put patch].include?(req.request_method.downcase)
        req.ip
      end
    end

    # DELETE requests (by IP)
    # Limit: 30 requests per minute
    Rack::Attack.throttle("api_delete/ip", limit: 30, period: 1.minute) do |req|
      req.delete? ? req.ip : nil
    end

    # Authenticated users (by user_id)
    # Limit: 600 requests per minute (higher priority than IP limits)
    Rack::Attack.throttle("api/user", limit: 600, period: 1.minute) do |req|
      # Extract user_id from JWT token if present
      token = req.env["HTTP_AUTHORIZATION"]&.split(" ")&.last
      if token
        begin
          decoded = JWT.decode(token, JWT_SECRET_KEY, false)
          decoded.first&.dig("sub")&.to_s
        rescue JWT::DecodeError
          nil
        end
      end
    end

    # ============================================
    # Custom Throttled Response
    # ============================================

    # Custom response for throttled requests (using throttled_responder for Rack::Attack 6.x)
    Rack::Attack.throttled_responder = lambda do |req|
      match_data = req.env["rack.attack.match_data"]

      # Calculate retry after time
      now = Time.now.to_i
      retry_after = match_data ? (match_data.period - (now % match_data.period)) : 60

      # Log throttled request
      Rails.logger.info "[Rack::Attack] Throttled: #{match_data&.name} for #{req.ip}"

      [
        429,
        {
          "Content-Type" => "application/json",
          "X-RateLimit-Limit" => match_data&.limit.to_s,
          "X-RateLimit-Remaining" => "0",
          "X-RateLimit-Reset" => (now + retry_after).to_s,
          "Retry-After" => retry_after.to_s
        },
        [
          {
            error: "Too many requests",
            retry_after: retry_after
          }.to_json
        ]
      ]
    end

    # ============================================
    # Logging
    # ============================================

    # Log throttled requests
    ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _request_id, payload|
      Rails.logger.info "[Rack::Attack] Throttled: #{payload[:request].path} for #{payload[:request].ip}"
    end
  end
end

# Apply configuration when middleware is used
Rails.application.config.middleware.use Rack::Attack
Rack::Attack::Config.configure
