# Redis store configuration for Rack::Attack
# Uses Rails credentials for Redis connection settings

Rails.application.config.after_initialize do
  redis_config = Rails.application.credentials.redis

  if redis_config&.url && Rails.env.production?
    # Use Redis in production
    begin
      require "redis"

      redis_client = Redis.new(
        url: redis_config.url,
        namespace: redis_config.namespace || "rack_attack"
      )

      Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
        redis: redis_client
      )
    rescue LoadError, StandardError => e
      Rails.logger.error "[Rack::Attack] Failed to initialize Redis: #{e.message}"
      Rails.logger.warn "[Rack::Attack] Falling back to memory store"
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    end
  else
    # Use memory store in development/test (Redis not required)
    Rails.logger.info "[Rack::Attack] Using memory store (development/test mode)"
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end
end
