require 'fileutils'

require 'rubygems'
require 'sinatra'

ROOT_DIR = File.dirname(__FILE__)

set :environment, ENV['RACK_ENV'].to_sym
set :root,        ROOT_DIR
set :app_file,    __FILE__
disable :run

helpers do
  def touch(name)
    FileUtils.touch("#{ROOT_DIR}/#{name}")
  end
end

post '/rails-master-hook' do
  touch 'run-rails-master-hook'
  content_type 'text/plain'

  <<BODY
Rails master hook tasks scheduled:

  * updates the local checkout
  * updates Rails Contributors
  * generates and publishes edge docs

If a new stable tag is detected it also

  * generates and publishes stable docs

This needs typically a few minutes.

Let the ZOMG be with you.
BODY
end

run Sinatra::Application