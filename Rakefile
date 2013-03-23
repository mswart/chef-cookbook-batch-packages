require 'rspec/core/rake_task'
require 'foodcritic'

task :default => [ :foodcritic, :spec ]

FoodCritic::Rake::LintTask.new do |task|
  task.options = { :fail_tags => [ 'any' ] }
end

RSpec::Core::RakeTask.new(:spec)
