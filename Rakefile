# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "."
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

task default: :test
