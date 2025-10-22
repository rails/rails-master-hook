# frozen_string_literal: true

# Application wrapper for testing
# This extracts the core application logic without loading config.ru

require "fileutils"
require "rack"
require "logger"
require_relative "lockfile_checker"

class RailsMasterHookApp
  def initialize(run_file: nil, lock_file: nil, logger:)
    @run_file = run_file || ENV["RUN_FILE"] || File.expand_path("../run-rails-master-hook", __dir__)
    @lock_file = lock_file || ENV["LOCK_FILE"]
    @logger = logger
  end

  def call(env)
    request = Rack::Request.new(env)

    # Handle rails-master-hook routes (with or without trailing slash)
    if request.path_info == "/rails-master-hook" || request.path_info == "/rails-master-hook/"
      handle_rails_master_hook(request)
    else
      handle_root(request)
    end
  end

  private

  def handle_rails_master_hook(request)
    if request.request_method == "POST"
      @logger.info "Triggering Rails master hook by touching #{@run_file}"
      FileUtils.touch(@run_file)
      @logger.info "Rails master hook scheduled successfully"

      scheduled = <<~EOS
        Rails master hook tasks scheduled:

        * updates the local checkout
        * updates Rails Contributors
        * generates and publishes edge docs

        If a new stable tag is detected it also

        * generates and publishes stable docs

        This needs typically a few minutes.
      EOS

      [200, {"Content-Type" => "text/plain", "Content-Length" => scheduled.length.to_s}, [scheduled]]
    else
      @logger.warn "Rejected non-POST request (#{request.request_method}) to /rails-master-hook"
      [404, {"Content-Type" => "text/plain", "Content-Length" => "0"}, []]
    end
  end

  def handle_root(request)
    lockfile_checker = LockfileChecker.new(@lock_file)

    if lockfile_checker.stale?
      age_minutes = lockfile_checker.age_in_minutes
      error_msg = "System down: Lock file has been present for more than 2 hours"
      @logger.error "#{error_msg} (actual age: #{age_minutes} minutes)"
      [503, {"Content-Type" => "text/plain", "Content-Length" => error_msg.length.to_s}, [error_msg]]
    else
      [200, {"Content-Type" => "text/plain", "Content-Length" => "4"}, ["PONG"]]
    end
  end
end
