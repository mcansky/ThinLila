task :rdoc do
  sh "rdoc --all --op doc"
end

task :cucumber do
  $:.unshift(File.dirname(__FILE__) + '../lib')
  begin
    require 'cucumber/rake/task'
    Cucumber::Rake::Task.new(:features)
  rescue LoadError
    puts "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = %w{--format pretty}
  end
end