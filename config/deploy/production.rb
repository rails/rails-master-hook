DOCS_SERVER_IP = '138.197.6.175'

set :ssh_options, port: 987
server DOCS_SERVER_IP, user: 'rails', roles: %w(web)

set :rvm_ruby_version, '3.3.4'
set :rvm_custom_path, '/home/rails/.rvm'
