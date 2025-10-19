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
scheduled = <<EOS
Rails master hook tasks scheduled:

* updates the local checkout
* updates Rails Contributors
* generates and publishes edge docs

If a new stable tag is detected it also

* generates and publishes stable docs

This needs typically a few minutes.
EOS

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
    [200, {"Content-Type" => "text/plain", "Content-Length" => "4"}, ["PONG"]]
  end
end
