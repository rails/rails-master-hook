listen 8080
worker_processes 1
pid "#{File.expand_path(File.dirname(__FILE__))}/unicorn.pid"