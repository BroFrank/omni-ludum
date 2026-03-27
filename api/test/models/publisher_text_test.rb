require "test_helper"

class PublisherTextTest < ActiveSupport::TestCase
  setup do
    @publisher = Publisher.create!(name: "Test Publisher", type: PUBLISHER_TYPES::PUBLISHER)
    @valid_attrs = {
      publisher: @publisher,
      lang_code: "en",
      description: "Test description"
    }
  end

  # ============================================
  # Basic validations
  # ============================================
  test "creates publisher_text with valid attributes" do
    pt = PublisherText.new(@valid_attrs)
    assert pt.valid?
  end

  test "publisher_id must be present" do
    pt = PublisherText.new(@valid_attrs.merge(publisher: nil))
    assert_not pt.valid?
    assert pt.errors.added?(:publisher_id, :blank)
  end

  test "lang_code must be present" do
    pt = PublisherText.new(@valid_attrs.merge(lang_code: nil))
    assert_not pt.valid?
    assert pt.errors.added?(:lang_code, :blank)
  end

  test "lang_code must be exactly 2 characters" do
    pt = PublisherText.new(@valid_attrs.merge(lang_code: "e"))
    assert_not pt.valid?
    assert pt.errors[:lang_code].any?

    pt = PublisherText.new(@valid_attrs.merge(lang_code: "eng"))
    assert_not pt.valid?
    assert pt.errors[:lang_code].any?
  end

  test "lang_code must be lowercase latin letters" do
    pt = PublisherText.new(@valid_attrs.merge(lang_code: "e1"))
    assert_not pt.valid?
    assert pt.errors[:lang_code].any?

    pt = PublisherText.new(@valid_attrs.merge(lang_code: "1n"))
    assert_not pt.valid?
    assert pt.errors[:lang_code].any?
  end

  test "description can be nil" do
    pt = PublisherText.new(@valid_attrs.merge(description: nil))
    assert pt.valid?
  end

  test "description has maximum length of 10000 characters" do
    pt = PublisherText.new(@valid_attrs.merge(description: "a" * 10001))
    assert_not pt.valid?
    assert pt.errors[:description].any?

    pt = PublisherText.new(@valid_attrs.merge(description: "a" * 10000))
    assert pt.valid?
  end

  test "lang_code is unique per publisher_id (case-insensitive)" do
    PublisherText.create!(@valid_attrs)

    pt = PublisherText.new(@valid_attrs)
    assert_not pt.valid?
    assert_includes pt.errors.full_messages, "Lang code has already been taken"
  end

  test "same lang_code is allowed for different publishers" do
    publisher2 = Publisher.create!(name: "Another Publisher", type: PUBLISHER_TYPES::PUBLISHER)
    PublisherText.create!(@valid_attrs)
    pt = PublisherText.new(@valid_attrs.merge(publisher: publisher2))
    assert pt.valid?
  end

  # ============================================
  # Lang code normalization
  # ============================================
  test "lang_code is normalized to lowercase" do
    pt = PublisherText.create!(@valid_attrs.merge(lang_code: "EN"))
    assert_equal "en", pt.lang_code
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only texts for active publishers" do
    active_publisher = Publisher.create!(name: "Active Pub", type: PUBLISHER_TYPES::PUBLISHER)
    disabled_publisher = Publisher.create!(name: "Disabled Pub", type: PUBLISHER_TYPES::PUBLISHER, is_disabled: true)

    active_pt = PublisherText.create!(@valid_attrs.merge(publisher: active_publisher))
    disabled_pt = PublisherText.create!(@valid_attrs.merge(publisher: disabled_publisher, lang_code: "ru"))

    assert_includes PublisherText.active, active_pt
    assert_not_includes PublisherText.active, disabled_pt
  end

  test "by_lang scope filters by language" do
    en_pt = PublisherText.create!(@valid_attrs)
    ru_pt = PublisherText.create!(@valid_attrs.merge(lang_code: "ru"))

    assert_includes PublisherText.by_lang("en"), en_pt
    assert_not_includes PublisherText.by_lang("en"), ru_pt
  end

  test "by_lang scope is case-insensitive" do
    en_pt = PublisherText.create!(@valid_attrs)

    assert_includes PublisherText.by_lang("EN"), en_pt
    assert_includes PublisherText.by_lang("en"), en_pt
  end

  test "for_publisher scope filters by publisher" do
    publisher2 = Publisher.create!(name: "Another Pub", type: PUBLISHER_TYPES::PUBLISHER)
    pt1 = PublisherText.create!(@valid_attrs)
    pt2 = PublisherText.create!(@valid_attrs.merge(publisher: publisher2, lang_code: "ru"))

    assert_includes PublisherText.for_publisher(@publisher.id), pt1
    assert_not_includes PublisherText.for_publisher(@publisher.id), pt2
  end

  # ============================================
  # Association
  # ============================================
  test "belongs_to publisher association" do
    pt = PublisherText.create!(@valid_attrs)
    assert_equal @publisher.id, pt.publisher_id
    assert_equal @publisher.name, pt.publisher.name
  end

  test "publisher_text is destroyed when publisher is destroyed" do
    pt = PublisherText.create!(@valid_attrs)
    @publisher.destroy
    assert_raises ActiveRecord::RecordNotFound do
      PublisherText.find(pt.id)
    end
  end
end
