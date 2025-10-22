# frozen_string_literal: true

require "fileutils"
require "rack"
require "logger"

# Setup logger - log to STDOUT for systemd
logger = Logger.new(STDOUT)
logger.level = ENV["LOG_LEVEL"] ? Logger.const_get(ENV["LOG_LEVEL"].upcase) : Logger::INFO
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end

# Use Rack::CommonLogger for HTTP request logging
use Rack::CommonLogger, logger

run_file  = ENV["RUN_FILE"] || "#{__dir__}/run-rails-master-hook"
lock_file = ENV["LOCK_FILE"]
scheduled = <<EOS
Rails master hook tasks scheduled:

* updates the local checkout
* updates Rails Contributors
* generates and publishes edge docs

If a new stable tag is detected it also

* generates and publishes stable docs

This needs typically a few minutes.
EOS

# Helper class for lockfile checking
class LockfileChecker
  def self.stale?(lock_file, logger)
    return false unless lock_file && File.exist?(lock_file)

    file_age = Time.now - File.mtime(lock_file)
    stale = file_age > 7200 # 2 hours in seconds

    if stale
      logger.warn "Lock file #{lock_file} is stale (age: #{(file_age / 60).round(1)} minutes)"
    else
      logger.debug "Lock file #{lock_file} age: #{(file_age / 60).round(1)} minutes"
    end

    stale
  end
end

map "/rails-master-hook" do
  run ->(env) do
    request_method = env["REQUEST_METHOD"]

    if request_method == "POST"
      logger.info "Triggering Rails master hook by touching #{run_file}"
      FileUtils.touch(run_file)
      logger.info "Rails master hook scheduled successfully"
      [200, {"Content-Type" => "text/plain", "Content-Length" => scheduled.length.to_s}, [scheduled]]
    else
      logger.warn "Rejected non-POST request (#{request_method}) to /rails-master-hook"
      [404, {"Content-Type" => "text/plain", "Content-Length" => "0"}, []]
    end
  end
end

map "/" do
  run ->(_env) do
    # Check if lockfile is stale (older than 2 hours)
    if LockfileChecker.stale?(lock_file, logger)
      error_msg = "System down: Lock file has been present for more than 2 hours"
      logger.error error_msg
      [503, {"Content-Type" => "text/plain", "Content-Length" => error_msg.length.to_s}, [error_msg]]
    else
      [200, {"Content-Type" => "text/plain", "Content-Length" => "4"}, ["PONG"]]
    end
  end
end
