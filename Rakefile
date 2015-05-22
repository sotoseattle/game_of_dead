require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.libs << ['lib', 'test']
  t.verbose = true
end

task default: "test"
