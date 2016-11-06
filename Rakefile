require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Run me to get an overview of using the API"
task :readme do
  require './README'
end
