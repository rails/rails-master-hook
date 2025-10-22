# frozen_string_literal: true

require_relative "test_helper"

class RailsMasterHookTest < TestCase
  def test_root_path_returns_pong_when_no_lock_file
    get "/"

    assert_equal 200, last_response.status
    assert_equal "PONG", last_response.body
    assert_equal "text/plain", last_response.content_type
    assert_equal "4", last_response.headers["Content-Length"]
  end

  def test_root_path_returns_pong_when_lock_file_is_fresh
    create_lock_file # Fresh lock file (0 seconds old)

    get "/"

    assert_equal 200, last_response.status
    assert_equal "PONG", last_response.body
    assert_equal "text/plain", last_response.content_type
  end

  def test_root_path_returns_error_when_lock_file_is_stale
    create_lock_file(7300) # 2+ hours old (stale)

    get "/"

    assert_equal 503, last_response.status
    assert_equal "System down: Lock file has been present for more than 2 hours", last_response.body
    assert_equal "text/plain", last_response.content_type
    log_output = log_content.string
    assert_match(/actual age: 121\.7 minutes/, log_output)
    assert_match(/System down: Lock file has been present for more than 2 hours/, log_output)
  end

  def test_root_path_returns_pong_when_lock_file_is_just_under_threshold
    create_lock_file(7100) # Just under 2 hours (not stale)

    get "/"

    assert_equal 200, last_response.status
    assert_equal "PONG", last_response.body
  end

  def test_rails_master_hook_post_creates_run_file
    refute run_file_exists?, "Run file should not exist initially"

    post "/rails-master-hook"

    assert_equal 200, last_response.status
    assert run_file_exists?, "Run file should be created after POST"
    assert_match(/Rails master hook tasks scheduled/, last_response.body)
    assert_equal "text/plain", last_response.content_type
  end

  def test_rails_master_hook_post_touches_existing_run_file
    FileUtils.touch(test_run_file)
    original_mtime = File.mtime(test_run_file)

    # Sleep to ensure time difference
    sleep 0.1

    post "/rails-master-hook"

    assert_equal 200, last_response.status
    new_mtime = File.mtime(test_run_file)
    assert new_mtime > original_mtime, "Run file should be touched (mtime updated)"
  end

  def test_rails_master_hook_post_response_content
    post "/rails-master-hook"

    assert_equal 200, last_response.status

    expected_content = <<~EOS
      Rails master hook tasks scheduled:

      * updates the local checkout
      * updates Rails Contributors
      * generates and publishes edge docs

      If a new stable tag is detected it also

      * generates and publishes stable docs

      This needs typically a few minutes.
    EOS

    assert_equal expected_content, last_response.body
    assert_equal expected_content.length.to_s, last_response.headers["Content-Length"]
  end

  def test_rails_master_hook_get_returns_404
    get "/rails-master-hook"

    assert_equal 404, last_response.status
    assert_equal "", last_response.body
    assert_equal "0", last_response.headers["Content-Length"]
  end

  def test_rails_master_hook_put_returns_404
    put "/rails-master-hook"

    assert_equal 404, last_response.status
    assert_equal "", last_response.body
  end

  def test_rails_master_hook_delete_returns_404
    delete "/rails-master-hook"

    assert_equal 404, last_response.status
    assert_equal "", last_response.body
  end

  def test_unknown_path_returns_pong
    get "/unknown-path"

    # Unknown paths are handled by the root mapper, so they return PONG
    assert_equal 200, last_response.status
    assert_equal "PONG", last_response.body
  end

  def test_nested_unknown_path_returns_pong
    get "/some/nested/path"

    # Unknown paths are handled by the root mapper, so they return PONG
    assert_equal 200, last_response.status
    assert_equal "PONG", last_response.body
  end

  def test_rails_master_hook_with_trailing_slash
    post "/rails-master-hook/"

    # Rack routing matches /rails-master-hook/ to /rails-master-hook
    assert_equal 200, last_response.status
    assert_match(/Rails master hook tasks scheduled/, last_response.body)
  end

  private

  def run_file_exists?
    File.exist?(test_run_file)
  end
end
