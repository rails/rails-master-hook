# frozen_string_literal: true

# Utility class for checking if lock files are stale
#
# A lock file is considered stale if it's older than 2 hours,
# which indicates a potentially stuck or long-running process.
class LockfileChecker
  # @param lock_file [String, nil] Path to the lock file to check
  def initialize(lock_file)
    @file_age_seconds = calculate_file_age(lock_file)
  end

  # Check if the lock file is stale (older than 2 hours)
  #
  # @return [Boolean] true if the lock file is stale, false otherwise
  def stale?
    return false if @file_age_seconds.nil?

    @file_age_seconds > 7200 # 2 hours in seconds
  end

  # Get the age of the lock file in minutes
  #
  # @return [Float, nil] Age in minutes, or nil if file doesn't exist
  def age_in_minutes
    return nil if @file_age_seconds.nil?

    (@file_age_seconds / 60).round(1)
  end

  private

  def calculate_file_age(lock_file)
    return nil unless lock_file && File.exist?(lock_file)

    Time.now - File.mtime(lock_file)
  end
end
