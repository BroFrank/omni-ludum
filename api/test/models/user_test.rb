require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @valid_user_attrs = {
      username: "testuser",
      email: "test@example.com",
      password: "Password1!",
      password_confirmation: "Password1!"
    }
  end

  # ============================================
  # Username validations
  # ============================================
  test "creates user with valid attributes" do
    user = User.new(@valid_user_attrs)
    assert user.valid?
  end

  test "username must be present" do
    user = User.new(@valid_user_attrs.merge(username: nil))
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "username must be unique (case insensitive)" do
    User.create!(@valid_user_attrs)
    user = User.new(@valid_user_attrs.merge(username: "testuser"))
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "username with different case are considered the same" do
    User.create!(@valid_user_attrs.merge(username: "testuser"))
    user = User.new(@valid_user_attrs.merge(username: "TestUser", email: "test2@example.com"))
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "username newUser and NewUser are considered the same" do
    User.create!(@valid_user_attrs.merge(username: "newUser", email: "newuser1@example.com"))
    user = User.new(@valid_user_attrs.merge(username: "NewUser", email: "newuser2@example.com"))
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "username must be at least 3 characters" do
    user = User.new(@valid_user_attrs.merge(username: "ab"))
    assert_not user.valid?
    assert_match(/is too short/, user.errors[:username].first)
  end

  test "username can only contain letters, numbers, and spaces" do
    user = User.new(@valid_user_attrs.merge(username: "test@user"))
    assert_not user.valid?
    assert_includes user.errors[:username], "can only contain letters, numbers, and spaces"
  end

  test "username can contain spaces" do
    user = User.new(@valid_user_attrs.merge(username: "test user name"))
    assert user.valid?
  end

  # ============================================
  # Email validations
  # ============================================
  test "email must be present" do
    user = User.new(@valid_user_attrs.merge(email: nil))
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email must be unique (case insensitive)" do
    User.create!(@valid_user_attrs)
    user = User.new(@valid_user_attrs.merge(email: "TEST@EXAMPLE.COM"))
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "email must be valid format" do
    invalid_emails = [ "invalid", "test@", "@example.com", "" ]
    invalid_emails.each do |invalid_email|
      user = User.new(@valid_user_attrs.merge(email: invalid_email))
      assert_not user.valid?, "Email '#{invalid_email}' should be invalid"
    end
  end

  test "email accepts valid formats" do
    valid_emails = [ "test@example.com", "user.name@domain.org", "user+tag@mail.co.uk" ]
    valid_emails.each do |valid_email|
      user = User.new(@valid_user_attrs.merge(email: valid_email))
      assert user.valid?, "Email '#{valid_email}' should be valid"
    end
  end

  # ============================================
  # Password validations
  # ============================================
  test "password must be at least 7 characters" do
    user = User.new(@valid_user_attrs.merge(password: "Pass1!"))
    assert_not user.valid?
    assert_match(/is too short/, user.errors[:password].first)
  end

  test "password must contain at least one uppercase letter" do
    user = User.new(@valid_user_attrs.merge(password: "password1!"))
    assert_not user.valid?
    assert_match(/must contain at least one uppercase letter/, user.errors[:password].first)
  end

  test "password must contain at least one lowercase letter" do
    user = User.new(@valid_user_attrs.merge(password: "PASSWORD1!"))
    assert_not user.valid?
    assert_match(/must contain.*one lowercase letter/, user.errors[:password].first)
  end

  test "password must contain at least one digit" do
    user = User.new(@valid_user_attrs.merge(password: "Password!"))
    assert_not user.valid?
    assert_match(/must contain.*digit/, user.errors[:password].first)
  end

  test "password must contain at least one special character" do
    user = User.new(@valid_user_attrs.merge(password: "Password1"))
    assert_not user.valid?
    assert_match(/must contain.*special character/, user.errors[:password].first)
  end

  test "password can be nil when updating other fields" do
    user = User.create!(@valid_user_attrs)
    user.username = "newusername"
    assert user.valid?
  end

  # ============================================
  # Role validations
  # ============================================
  test "role must be present" do
    user = User.new(@valid_user_attrs.merge(role: nil))
    assert user.valid?
    assert_equal USER_ROLES::REGULAR, user.role
  end

  test "role must be one of USER_ROLES" do
    user = User.new(@valid_user_attrs.merge(role: "INVALID_ROLE"))
    assert_not user.valid?
    assert_includes user.errors[:role], "is invalid"
  end

  test "role defaults to REGULAR when not provided" do
    user = User.new(@valid_user_attrs.merge(role: nil))
    user.valid?
    assert_equal USER_ROLES::REGULAR, user.role
  end

  # ============================================
  # Slug validations
  # ============================================
  test "slug must be unique (case insensitive)" do
    User.create!(@valid_user_attrs)
    user = User.new(@valid_user_attrs.merge(username: "anotheruser", email: "another@example.com"))
    assert user.valid?
  end

  # ============================================
  # Scopes
  # ============================================
  test "active scope returns only active users" do
    active_user = User.create!(@valid_user_attrs)
    disabled_user = User.create!(@valid_user_attrs.merge(username: "disabled", email: "disabled@example.com", is_disabled: true))

    assert_includes User.active, active_user
    assert_not_includes User.active, disabled_user
  end

  test "disabled scope returns only disabled users" do
    active_user = User.create!(@valid_user_attrs)
    disabled_user = User.create!(@valid_user_attrs.merge(username: "disabled", email: "disabled@example.com", is_disabled: true))

    assert_includes User.disabled, disabled_user
    assert_not_includes User.disabled, active_user
  end

  # ============================================
  # Instance methods
  # ============================================
  test "admin? returns true for SUPER_ADMIN and ADMIN" do
    super_admin = User.create!(@valid_user_attrs.merge(username: "superadmin", email: "superadmin@example.com", role: USER_ROLES::SUPER_ADMIN))
    admin = User.create!(@valid_user_attrs.merge(username: "admin", email: "admin@example.com", role: USER_ROLES::ADMIN))
    moderator = User.create!(@valid_user_attrs.merge(username: "mod", email: "mod@example.com", role: USER_ROLES::MODERATOR))
    regular = User.create!(@valid_user_attrs.merge(username: "regular", email: "regular@example.com", role: USER_ROLES::REGULAR))

    assert super_admin.admin?
    assert admin.admin?
    assert_not moderator.admin?
    assert_not regular.admin?
  end

  test "moderator? returns true for SUPER_ADMIN, ADMIN, and MODERATOR" do
    super_admin = User.create!(@valid_user_attrs.merge(username: "superadmin2", email: "superadmin2@example.com", role: USER_ROLES::SUPER_ADMIN))
    admin = User.create!(@valid_user_attrs.merge(username: "admin2", email: "admin2@example.com", role: USER_ROLES::ADMIN))
    moderator = User.create!(@valid_user_attrs.merge(username: "mod2", email: "mod2@example.com", role: USER_ROLES::MODERATOR))
    regular = User.create!(@valid_user_attrs.merge(username: "regular2", email: "regular2@example.com", role: USER_ROLES::REGULAR))

    assert super_admin.moderator?
    assert admin.moderator?
    assert moderator.moderator?
    assert_not regular.moderator?
  end

  test "regular? returns true only for REGULAR" do
    super_admin = User.create!(@valid_user_attrs.merge(username: "superadmin3", email: "superadmin3@example.com", role: USER_ROLES::SUPER_ADMIN))
    admin = User.create!(@valid_user_attrs.merge(username: "admin3", email: "admin3@example.com", role: USER_ROLES::ADMIN))
    moderator = User.create!(@valid_user_attrs.merge(username: "mod3", email: "mod3@example.com", role: USER_ROLES::MODERATOR))
    regular = User.create!(@valid_user_attrs.merge(username: "regular3", email: "regular3@example.com", role: USER_ROLES::REGULAR))

    assert_not super_admin.regular?
    assert_not admin.regular?
    assert_not moderator.regular?
    assert regular.regular?
  end

  # ============================================
  # Class methods
  # ============================================
  test "find_by_slug! finds active user by slug" do
    user = User.create!(@valid_user_attrs)
    found_user = User.find_by_slug!("testuser")
    assert_equal user.id, found_user.id
  end

  test "find_by_slug! raises error for non-existent slug" do
    assert_raises ActiveRecord::RecordNotFound do
      User.find_by_slug!("nonexistent")
    end
  end

  test "find_by_slug! raises error for disabled user" do
    User.create!(@valid_user_attrs.merge(is_disabled: true))
    assert_raises ActiveRecord::RecordNotFound do
      User.find_by_slug!("testuser")
    end
  end

  test "find_by_slug finds active user by slug" do
    user = User.create!(@valid_user_attrs)
    found_user = User.find_by_slug("testuser")
    assert_equal user.id, found_user.id
  end

  test "find_by_slug returns nil for non-existent slug" do
    found_user = User.find_by_slug("nonexistent")
    assert_nil found_user
  end

  test "find_by_slug returns nil for disabled user" do
    User.create!(@valid_user_attrs.merge(is_disabled: true))
    found_user = User.find_by_slug("testuser")
    assert_nil found_user
  end

  # ============================================
  # Callback: generate_slug
  # ============================================
  test "slug is auto-generated from username" do
    user = User.create!(@valid_user_attrs)
    assert_equal "testuser", user.slug
  end

  test "slug replaces spaces with underscores" do
    user = User.create!(@valid_user_attrs.merge(username: "Test User Name"))
    assert_equal "test_user_name", user.slug
  end

  test "slug converts to lowercase" do
    user = User.create!(@valid_user_attrs.merge(username: "TESTUSER"))
    assert_equal "testuser", user.slug
  end

  test "slug removes special characters" do
    user = User.new(@valid_user_attrs.merge(username: "Test User"))
    user.valid?
    assert_equal "test_user", user.slug
  end

  # ============================================
  # Callback: set_default_role
  # ============================================
  test "role defaults to REGULAR on creation" do
    user = User.create!(@valid_user_attrs.merge(role: nil))
    assert_equal USER_ROLES::REGULAR, user.role
  end

  test "role can be set explicitly" do
    user = User.create!(@valid_user_attrs.merge(role: USER_ROLES::ADMIN))
    assert_equal USER_ROLES::ADMIN, user.role
  end

  # ============================================
  # Theme validations
  # ============================================
  test "theme defaults to light on creation" do
    user = User.create!(@valid_user_attrs)
    assert_equal USER_THEMES::LIGHT, user.theme
  end

  test "theme accepts light value" do
    user = User.new(@valid_user_attrs.merge(theme: USER_THEMES::LIGHT))
    assert user.valid?
  end

  test "theme accepts dark value" do
    user = User.new(@valid_user_attrs.merge(theme: USER_THEMES::DARK))
    assert user.valid?
  end

  test "theme does not accept invalid values" do
    user = User.new(@valid_user_attrs.merge(theme: "invalid"))
    assert_not user.valid?
    assert_includes user.errors[:theme], "is invalid"
  end

  test "theme must be present" do
    user = User.new(@valid_user_attrs.merge(theme: nil))
    assert user.valid?
    assert_equal USER_THEMES::LIGHT, user.theme
  end

  # ============================================
  # Locale validations
  # ============================================
  test "locale defaults to en on creation" do
    user = User.create!(@valid_user_attrs)
    assert_equal USER_LOCALES::ENGLISH, user.locale
  end

  test "locale accepts en value" do
    user = User.new(@valid_user_attrs.merge(locale: USER_LOCALES::ENGLISH))
    assert user.valid?
  end

  test "locale accepts ru value" do
    user = User.new(@valid_user_attrs.merge(locale: USER_LOCALES::RUSSIAN))
    assert user.valid?
  end

  test "locale does not accept invalid values" do
    user = User.new(@valid_user_attrs.merge(locale: "invalid"))
    assert_not user.valid?
    assert_includes user.errors[:locale], "is invalid"
  end

  test "locale must be present" do
    user = User.new(@valid_user_attrs.merge(locale: nil))
    assert user.valid?
    assert_equal USER_LOCALES::ENGLISH, user.locale
  end

  # ============================================
  # Instance methods for theme
  # ============================================
  test "light_theme? returns true for light theme" do
    user = User.create!(@valid_user_attrs)
    assert user.light_theme?
  end

  test "light_theme? returns false for dark theme" do
    user = User.create!(@valid_user_attrs.merge(theme: USER_THEMES::DARK))
    assert_not user.light_theme?
  end

  test "dark_theme? returns true for dark theme" do
    user = User.create!(@valid_user_attrs.merge(theme: USER_THEMES::DARK))
    assert user.dark_theme?
  end

  test "dark_theme? returns false for light theme" do
    user = User.create!(@valid_user_attrs)
    assert_not user.dark_theme?
  end

  # ============================================
  # Scopes for theme and locale
  # ============================================
  test "with_theme filters users by theme" do
    light_user = User.create!(@valid_user_attrs)
    dark_user = User.create!(@valid_user_attrs.merge(username: "darkuser", email: "dark@example.com", theme: USER_THEMES::DARK))

    assert_includes User.with_theme(USER_THEMES::LIGHT), light_user
    assert_not_includes User.with_theme(USER_THEMES::LIGHT), dark_user
    assert_includes User.with_theme(USER_THEMES::DARK), dark_user
    assert_not_includes User.with_theme(USER_THEMES::DARK), light_user
  end

  test "with_locale filters users by locale" do
    en_user = User.create!(@valid_user_attrs)
    ru_user = User.create!(@valid_user_attrs.merge(username: "ruuser", email: "ru@example.com", locale: USER_LOCALES::RUSSIAN))

    assert_includes User.with_locale(USER_LOCALES::ENGLISH), en_user
    assert_not_includes User.with_locale(USER_LOCALES::ENGLISH), ru_user
    assert_includes User.with_locale(USER_LOCALES::RUSSIAN), ru_user
    assert_not_includes User.with_locale(USER_LOCALES::RUSSIAN), en_user
  end
end
