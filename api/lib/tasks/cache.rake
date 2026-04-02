namespace :cache do
  desc "Clear all caches"
  task clear: :environment do
    Rails.cache.clear
    puts "All caches cleared"
  end

  desc "Clear genres cache"
  task clear_genres: :environment do
    Rails.cache.delete("genres/v1/active_ordered")
    puts "Genres cache cleared"
  end

  desc "Clear platforms cache"
  task clear_platforms: :environment do
    Rails.cache.delete("platforms/v1/active_ordered")
    puts "Platforms cache cleared"
  end

  desc "Clear publishers cache"
  task clear_publishers: :environment do
    Rails.cache.delete("publishers/v1/active_ordered")
    puts "Publishers cache cleared"
  end

  desc "Clear all reference data caches"
  task clear_references: :environment do
    Rails.cache.delete("genres/v1/active_ordered")
    Rails.cache.delete("platforms/v1/active_ordered")
    Rails.cache.delete("publishers/v1/active_ordered")
    puts "Reference data caches cleared"
  end
end
