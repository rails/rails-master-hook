# frozen_string_literal: true

require "fileutils"
require "rack"

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
    if env["REQUEST_METHOD"] == "POST"
      FileUtils.touch(run_file)
      [200, {"Content-Type" => "text/plain", "Content-Length" => scheduled.length.to_s}, [scheduled]]
    else
      [404, {"Content-Type" => "text/plain", "Content-Length" => "0"}, []]
    end
  end
end

map "/" do
  run ->(_env) do
    [200, {"Content-Type" => "text/plain", "Content-Length" => "4"}, ["PONG"]]
  end
end
