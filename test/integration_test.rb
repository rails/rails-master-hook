# frozen_string_literal: true

require_relative "test_helper"

class IntegrationTest < TestCase
  def test_config_ru_app_behaves_correctly
    capture_io do
      app, _options = Rack::Builder.parse_file(File.expand_path("../config.ru", __dir__))

      env = Rack::MockRequest.env_for("/")
      status, headers, body = app.call(env)

      assert_equal 200, status
      assert_equal "PONG", body.first
      assert_equal "text/plain", headers["Content-Type"]
    end
  end

  def test_config_ru_rails_master_hook_endpoint
    capture_io do
      app, _options = Rack::Builder.parse_file(File.expand_path("../config.ru", __dir__))

      env = Rack::MockRequest.env_for("/rails-master-hook", method: "POST")
        status, headers, body = app.call(env)

      assert_equal 200, status
      assert_match(/Rails master hook tasks scheduled/, body.first)
      assert_equal "text/plain", headers["Content-Type"]
    end
  end
end
