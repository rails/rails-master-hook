require 'fileutils'
require 'rack'

ROOT_DIR = File.dirname(__FILE__)
RSP_BODY = <<TXT
Rails master hook tasks scheduled:

  * updates the local checkout
  * updates Rails Contributors
  * generates and publishes edge docs

If a new stable tag is detected it also

  * generates and publishes stable docs

This needs typically a few minutes.
TXT

rails_master_hook = lambda do |env|
  if env['REQUEST_METHOD'] == 'POST'
    FileUtils.touch("#{ROOT_DIR}/run-rails-master-hook")
    [200, {'Content-Type' => 'text/plain', 'Content-Length' => RSP_BODY.length.to_s}, [RSP_BODY]]
  else
    [404, {'Content-Type' => 'text/plain', 'Content-Length' => '0'}, []]
  end
end

map '/rails-master-hook' do
  run rails_master_hook
end

