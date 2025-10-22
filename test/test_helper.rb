# frozen_string_literal: true

require "minitest/autorun"
require "rack/test"
require "rack/lint"
require "tmpdir"
require "stringio"

require_relative "../lib/rails_master_hook_app"

class TestCase < Minitest::Test
  include Rack::Test::Methods

  attr_reader :test_run_file, :test_lock_file, :log_content

  def app
    @app ||= begin
      test_logger = Logger.new(@log_content)
      test_logger.level = Logger::ERROR

      rails_app = RailsMasterHookApp.new(
        run_file: test_run_file,
        lock_file: test_lock_file,
        logger: test_logger
      )

      Rack::Lint.new(rails_app)
    end
  end

  def setup
    @temp_dir = Dir.mktmpdir("rails-master-hook-test")
    @test_run_file = File.join(@temp_dir, "run-rails-master-hook")
    @test_lock_file = File.join(@temp_dir, "lock")
    @log_content = StringIO.new
  end

  def teardown
    FileUtils.rm_rf(@temp_dir) if @temp_dir
  end

  def create_lock_file(age_in_seconds = 0)
    FileUtils.touch(test_lock_file)
    # Set the file's modification time to simulate age
    if age_in_seconds > 0
      past_time = Time.now - age_in_seconds
      File.utime(past_time, past_time, test_lock_file)
    end
  end
end
