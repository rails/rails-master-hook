# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "rails-master-hook"
set :repo_url, "https://github.com/rails/rails-master-hook.git"

set :deploy_to, "/home/rails/rails-master-hook-deploy"

set :keep_releases, 5

set :puma_bind, "tcp://0.0.0.0:9292"
set :puma_systemctl_user, :system
