# frozen_string_literal: true

require "logger"
require "rack"
require_relative "lib/rails_master_hook_app"

# Setup logger - log to STDOUT for systemd
logger = Logger.new($stdout)
logger.level = ENV["LOG_LEVEL"] ? Logger.const_get(ENV["LOG_LEVEL"].upcase) : Logger::INFO
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end

# Use Rack::CommonLogger for HTTP request logging
use Rack::CommonLogger, logger

run RailsMasterHookApp.new(logger: logger)
