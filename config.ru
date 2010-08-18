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
end

run Sinatra::Application