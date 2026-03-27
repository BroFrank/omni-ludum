require "test_helper"

class PublisherTest < ActiveSupport::TestCase
  setup do
    @valid_publisher_attrs = {
      name: "Test Publisher",
      type: PUBLISHER_TYPES::PUBLISHER
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates publisher with valid attributes" do
    publisher = Publisher.new(@valid_publisher_attrs)
    assert publisher.valid?
  end

  test "name must be present" do
    publisher = Publisher.new(@valid_publisher_attrs.merge(name: nil))
    assert_not publisher.valid?
    assert publisher.errors.added?(:name, :blank)
  end

  test "name must be unique (case-insensitive)" do
    Publisher.create!(@valid_publisher_attrs)
    publisher = Publisher.new(@valid_publisher_attrs.merge(name: "test publisher"))
    assert_not publisher.valid?
    assert publisher.errors.added?(:name, :taken)
  end

  test "type must be present" do
    publisher = Publisher.new(@valid_publisher_attrs.merge(type: nil))
    assert_not publisher.valid?
    assert publisher.errors.added?(:type, :blank)
  end

  test "type must be one of valid types" do
    publisher = Publisher.new(@valid_publisher_attrs.merge(type: "INVALID"))
    assert_not publisher.valid?
    assert publisher.errors[:type].any?
  end

  test "slug must be present" do
    publisher = Publisher.new(name: nil, type: PUBLISHER_TYPES::PUBLISHER, slug: nil)
    assert_not publisher.valid?
    assert publisher.errors.added?(:slug, :blank)
  end

  test "slug must be unique (case-insensitive)" do
    Publisher.create!(@valid_publisher_attrs.merge(slug: "test-slug"))
    publisher = Publisher.new(@valid_publisher_attrs.merge(slug: "TEST-SLUG"))
    assert_not publisher.valid?
    assert publisher.errors.added?(:slug, :taken)
  end

  # ============================================
  # Auto-generated slug
  # ============================================
  test "slug is auto-generated from name" do
    publisher = Publisher.create!(@valid_publisher_attrs.merge(slug: nil))
    assert_equal "test-publisher", publisher.slug
  end

  test "slug generation handles spaces" do
    publisher = Publisher.create!(name: "Test Publisher Name", type: PUBLISHER_TYPES::PUBLISHER)
    assert_equal "test-publisher-name", publisher.slug
  end

  test "slug generation handles special characters" do
    publisher = Publisher.create!(name: "Test & Co.", type: PUBLISHER_TYPES::PUBLISHER)
    assert_equal "test-co", publisher.slug
  end

  test "slug generation handles uppercase" do
    publisher = Publisher.create!(name: "TEST PUBLISHER", type: PUBLISHER_TYPES::PUBLISHER)
    assert_equal "test-publisher", publisher.slug
  end

  test "custom slug is preserved" do
    publisher = Publisher.create!(@valid_publisher_attrs.merge(slug: "custom-slug"))
    assert_equal "custom-slug", publisher.slug
  end

  # ============================================
  # Type normalization
  # ============================================
  test "type is normalized to uppercase" do
    publisher = Publisher.create!(@valid_publisher_attrs.merge(type: "publisher"))
    assert_equal "PUBLISHER", publisher.type
  end

  test "type accepts lowercase developer" do
    publisher = Publisher.create!(@valid_publisher_attrs.merge(type: "developer"))
    assert_equal "DEVELOPER", publisher.type
  end

  test "type accepts lowercase person" do
    publisher = Publisher.create!(@valid_publisher_attrs.merge(type: "person"))
    assert_equal "PERSON", publisher.type
  end

  # ============================================
  # Boolean fields default values
  # ============================================
  test "is_disabled defaults to false" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    assert_equal false, publisher.is_disabled
  end

  test "is_disabled can be set to true" do
    publisher = Publisher.create!(@valid_publisher_attrs.merge(is_disabled: true))
    assert publisher.is_disabled
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only active publishers" do
    active_publisher = Publisher.create!(@valid_publisher_attrs)
    disabled_publisher = Publisher.create!(@valid_publisher_attrs.merge(name: "Disabled Publisher", is_disabled: true))

    assert_includes Publisher.active, active_publisher
    assert_not_includes Publisher.active, disabled_publisher
  end

  test "disabled scope returns only disabled publishers" do
    active_publisher = Publisher.create!(@valid_publisher_attrs)
    disabled_publisher = Publisher.create!(@valid_publisher_attrs.merge(name: "Disabled Publisher", is_disabled: true))

    assert_includes Publisher.disabled, disabled_publisher
    assert_not_includes Publisher.disabled, active_publisher
  end

  test "publishers scope returns only publisher type" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    developer = Publisher.create!(@valid_publisher_attrs.merge(name: "Dev Studio", type: PUBLISHER_TYPES::DEVELOPER))
    person = Publisher.create!(@valid_publisher_attrs.merge(name: "John Doe", type: PUBLISHER_TYPES::PERSON))

    assert_includes Publisher.publishers, publisher
    assert_not_includes Publisher.publishers, developer
    assert_not_includes Publisher.publishers, person
  end

  test "developers scope returns only developer type" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    developer = Publisher.create!(@valid_publisher_attrs.merge(name: "Dev Studio", type: PUBLISHER_TYPES::DEVELOPER))
    person = Publisher.create!(@valid_publisher_attrs.merge(name: "John Doe", type: PUBLISHER_TYPES::PERSON))

    assert_includes Publisher.developers, developer
    assert_not_includes Publisher.developers, publisher
    assert_not_includes Publisher.developers, person
  end

  test "persons scope returns only person type" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    developer = Publisher.create!(@valid_publisher_attrs.merge(name: "Dev Studio", type: PUBLISHER_TYPES::DEVELOPER))
    person = Publisher.create!(@valid_publisher_attrs.merge(name: "John Doe", type: PUBLISHER_TYPES::PERSON))

    assert_includes Publisher.persons, person
    assert_not_includes Publisher.persons, publisher
    assert_not_includes Publisher.persons, developer
  end

  # ============================================
  # Instance methods
  # ============================================
  test "publisher? returns true for publisher type" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    assert publisher.publisher?
  end

  test "publisher? returns false for developer type" do
    developer = Publisher.create!(@valid_publisher_attrs.merge(name: "Dev Studio", type: PUBLISHER_TYPES::DEVELOPER))
    assert_not developer.publisher?
  end

  test "publisher? returns false for person type" do
    person = Publisher.create!(@valid_publisher_attrs.merge(name: "John Doe", type: PUBLISHER_TYPES::PERSON))
    assert_not person.publisher?
  end

  test "developer? returns true for developer type" do
    developer = Publisher.create!(@valid_publisher_attrs.merge(name: "Dev Studio", type: PUBLISHER_TYPES::DEVELOPER))
    assert developer.developer?
  end

  test "developer? returns false for publisher type" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    assert_not publisher.developer?
  end

  test "person? returns true for person type" do
    person = Publisher.create!(@valid_publisher_attrs.merge(name: "John Doe", type: PUBLISHER_TYPES::PERSON))
    assert person.person?
  end

  test "person? returns false for publisher type" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    assert_not publisher.person?
  end

  test "disable! sets is_disabled to true" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    publisher.disable!
    assert publisher.is_disabled
  end

  test "restore! sets is_disabled to false" do
    publisher = Publisher.create!(@valid_publisher_attrs.merge(is_disabled: true))
    publisher.restore!
    assert_not publisher.is_disabled
  end

  # ============================================
  # Class methods
  # ============================================
  test "find_by_slug! finds active publisher by slug" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    found_publisher = Publisher.find_by_slug!("test-publisher")
    assert_equal publisher.id, found_publisher.id
  end

  test "find_by_slug! raises error for non-existent slug" do
    assert_raises ActiveRecord::RecordNotFound do
      Publisher.find_by_slug!("nonexistent")
    end
  end

  test "find_by_slug! raises error for disabled publisher" do
    Publisher.create!(@valid_publisher_attrs.merge(is_disabled: true))
    assert_raises ActiveRecord::RecordNotFound do
      Publisher.find_by_slug!("test-publisher")
    end
  end

  test "find_by_slug finds active publisher by slug" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    found_publisher = Publisher.find_by_slug("test-publisher")
    assert_equal publisher.id, found_publisher.id
  end

  test "find_by_slug returns nil for non-existent slug" do
    found_publisher = Publisher.find_by_slug("nonexistent")
    assert_nil found_publisher
  end

  test "find_by_slug returns nil for disabled publisher" do
    Publisher.create!(@valid_publisher_attrs.merge(is_disabled: true))
    found_publisher = Publisher.find_by_slug("test-publisher")
    assert_nil found_publisher
  end

  # ============================================
  # Games association
  # ============================================
  test "publisher can have many games" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    game1 = Game.create!(name: "Game 1", release_year: 2020, publisher: publisher)
    game2 = Game.create!(name: "Game 2", release_year: 2021, publisher: publisher)

    assert_equal 2, publisher.games.count
    assert_includes publisher.games, game1
    assert_includes publisher.games, game2
  end

  test "games are nullified when publisher is disabled" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    game = Game.create!(name: "Test Game", release_year: 2020, publisher: publisher)

    publisher.disable!

    game.reload
    assert_nil game.publisher_id
  end

  test "publisher has many publisher_texts" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    en_text = PublisherText.create!(publisher: publisher, lang_code: "en", description: "English description")
    ru_text = PublisherText.create!(publisher: publisher, lang_code: "ru", description: "Русское описание")

    assert_equal 2, publisher.publisher_texts.count
    assert_includes publisher.publisher_texts, en_text
    assert_includes publisher.publisher_texts, ru_text
  end

  test "publisher_texts are destroyed when publisher is destroyed" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    PublisherText.create!(publisher: publisher, lang_code: "en", description: "Description")

    publisher.destroy

    assert_equal 0, PublisherText.count
  end

  test "description_for returns description for specified locale" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    PublisherText.create!(publisher: publisher, lang_code: "en", description: "English description")
    PublisherText.create!(publisher: publisher, lang_code: "ru", description: "Русское описание")

    assert_equal "English description", publisher.description_for("en")
    assert_equal "Русское описание", publisher.description_for("ru")
    assert_nil publisher.description_for("fr")
  end

  test "description_for is case-insensitive" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    PublisherText.create!(publisher: publisher, lang_code: "en", description: "English description")

    assert_equal "English description", publisher.description_for("EN")
    assert_equal "English description", publisher.description_for("en")
  end

  test "all_descriptions returns descriptions ordered by lang_code" do
    publisher = Publisher.create!(@valid_publisher_attrs)
    PublisherText.create!(publisher: publisher, lang_code: "ru", description: "Русское описание")
    PublisherText.create!(publisher: publisher, lang_code: "en", description: "English description")

    descriptions = publisher.all_descriptions.to_a

    assert_equal 2, descriptions.count
    assert_equal "en", descriptions.first.lang_code
    assert_equal "ru", descriptions.second.lang_code
  end
end
