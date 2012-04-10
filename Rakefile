require 'pathname'
__LIB__ = Pathname.new(__FILE__).expand_path.dirname.join('lib').to_s
$:.unshift(__LIB__) unless $:.include?(__LIB__)
require 'outline'

def notify(message)
  start_time = Time.now
  puts "-- #{message}"
  yield
  puts "   -> #{'%0.04f' % (Time.now - start_time)}s"
end

namespace :gem do
  desc 'Update the VERSION file to the latest version'
  task :update_version do
    notify "updating VERSION to #{Outline::VERSION}" do
      File.open('VERSION', 'w+') { |f| f.print Outline::VERSION }
    end
  end
  
  desc 'Build the gem'
  task :build do
    notify 'building the gem' do
      `gem build *.gemspec`
    end
  end
  
  desc 'Push the gem to RubyGems'
  task :push do
    notify 'pushing gem' do
      `gem push *.gem`
    end
  end
  
  desc 'Move the gem to the pkg directory'
  task :move do
    notify 'moving the gem to pkg/' do
      `mv *.gem pkg/`
    end
  end
  
  desc 'Update VERSION, build the gem, push the gem, then move the gem to the pkg directory'
  task deploy: [:update_version, :build, :push, :move]
end

desc "Run all specs"
task :spec do
  sh 'bundle exec rspec spec'
end