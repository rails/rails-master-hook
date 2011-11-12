require 'fileutils'
require 'rack'

ROOT_DIR = File.dirname(__FILE__)

rails_master_hook = lambda do |env|
  if env['REQUEST_METHOD'] == 'POST'
    FileUtils.touch("#{ROOT_DIR}/run-rails-master-hook")
    [200, {"Content-Type" => "text/plain"}, []]
  else
    [404, {"Content-Type" => "text/plain"}, []]
  end
end

run Rack::Builder.new {
  map "/rails-master-hook" do
    run rails_master_hook
  end
}
