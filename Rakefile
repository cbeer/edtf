require 'bundler/gem_tasks'

Dir.glob('lib/tasks/*.rake').each { |r| import r }

require 'rake'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :console do
    sh "irb -rubygems -I lib -r edtf.rb"
end
