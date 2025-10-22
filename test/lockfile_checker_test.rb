# frozen_string_literal: true

require_relative "test_helper"

class LockfileCheckerTest < TestCase
  def test_stale_returns_false_when_no_lock_file
    non_existent_file = File.join(@temp_dir, "non_existent")
    checker = LockfileChecker.new(non_existent_file)

    refute checker.stale?
  end

  def test_stale_returns_false_when_lock_file_is_nil
    checker = LockfileChecker.new(nil)

    refute checker.stale?
  end

  def test_stale_returns_false_when_lock_file_is_fresh
    create_lock_file # Fresh file (0 seconds old)
    checker = LockfileChecker.new(test_lock_file)

    refute checker.stale?
  end

  def test_stale_returns_false_when_lock_file_is_under_threshold
    create_lock_file(3600) # 1 hour old (under 2 hour threshold)
    checker = LockfileChecker.new(test_lock_file)

    refute checker.stale?
  end

  def test_stale_returns_false_when_lock_file_is_just_at_threshold
    create_lock_file(7199) # Just under 2 hours old
    checker = LockfileChecker.new(test_lock_file)

    refute checker.stale?
  end

  def test_stale_returns_true_when_lock_file_is_over_threshold
    create_lock_file(7201) # Just over 2 hours old
    checker = LockfileChecker.new(test_lock_file)

    assert checker.stale?
  end

  def test_stale_returns_true_when_lock_file_is_very_old
    create_lock_file(86400) # 24 hours old
    checker = LockfileChecker.new(test_lock_file)

    assert checker.stale?
  end

  def test_age_in_minutes_returns_nil_when_file_does_not_exist
    non_existent_file = File.join(@temp_dir, "non_existent")
    checker = LockfileChecker.new(non_existent_file)

    assert_nil checker.age_in_minutes
  end

  def test_age_in_minutes_returns_nil_when_file_is_nil
    checker = LockfileChecker.new(nil)

    assert_nil checker.age_in_minutes
  end

  def test_age_in_minutes_returns_correct_age_for_fresh_file
    create_lock_file # Fresh file (0 seconds old)
    checker = LockfileChecker.new(test_lock_file)

    age = checker.age_in_minutes
    assert age >= 0
    assert age < 1 # Should be less than 1 minute
  end

  def test_age_in_minutes_returns_correct_age_for_old_file
    create_lock_file(5400) # 90 minutes old
    checker = LockfileChecker.new(test_lock_file)

    age = checker.age_in_minutes
    assert_equal 90.0, age
  end

  def test_age_in_minutes_handles_fractional_minutes
    create_lock_file(1830) # 30.5 minutes old
    checker = LockfileChecker.new(test_lock_file)

    age = checker.age_in_minutes
    assert_equal 30.5, age
  end

  def test_age_remains_consistent_between_calls
    create_lock_file(7201) # Just over 2 hours old (stale)
    checker = LockfileChecker.new(test_lock_file)

    # First calls
    first_stale_result = checker.stale?
    first_age = checker.age_in_minutes

    # Sleep a bit to ensure time has passed
    sleep 0.01

    # Second calls - should return exactly the same values
    second_stale_result = checker.stale?
    second_age = checker.age_in_minutes

    assert_equal first_stale_result, second_stale_result
    assert_equal first_age, second_age
    assert first_stale_result # Should be stale (over threshold)
    assert_equal 120.0, first_age # Should be approximately 120 minutes
  end
end
