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

VERSION_REGEXP = /VERSION = '((\d+)\.(\d+)\.(\d+))'/

namespace :version do
  desc 'Display the current version'
  task :current do
    puts File.read('VERSION')
  end
  
  desc 'Update the version file to the latest version'
  task :update_file do
    notify "updating VERSION file to #{Outline::VERSION}" do
      File.open('VERSION', 'w+') { |f| f.print Outline::VERSION }
    end
  end
  
  namespace :bump do
    desc 'Bump the major version'
    task :major do
      data = File.read('lib/outline.rb')
      
      versions = { old: {}, new: {} }
      versions[:old][:major], versions[:old][:minor], versions[:old][:patch] = data.match(VERSION_REGEXP).captures[1..-1].collect { |i| i.to_i }
      versions[:new] = versions[:old].dup
      versions[:new][:major] += 1
      versions[:new][:minor] = 0
      versions[:new][:patch] = 0
      versions[:old][:string] = [ versions[:old][:major], versions[:old][:minor], versions[:old][:patch] ].join('.')
      versions[:new][:string] = [ versions[:new][:major], versions[:new][:minor], versions[:new][:patch] ].join('.')
      
      notify "updating version from #{versions[:old][:string]} to #{versions[:new][:string]}" do
        File.open('lib/outline.rb', 'w+') { |f| f.print data.gsub(VERSION_REGEXP, "VERSION = '#{versions[:new][:string]}'") }
        Outline::VERSION.replace(versions[:new][:string])
      end
      
      Rake::Task["version:update_file"].execute
    end
    
    desc 'Bump the minor version'
    task :minor do
      data = File.read('lib/outline.rb')
      
      versions = { old: {}, new: {} }
      versions[:old][:major], versions[:old][:minor], versions[:old][:patch] = data.match(VERSION_REGEXP).captures[1..-1].collect { |i| i.to_i }
      versions[:new] = versions[:old].dup
      versions[:new][:minor] += 1
      versions[:new][:patch] = 0
      versions[:old][:string] = [ versions[:old][:major], versions[:old][:minor], versions[:old][:patch] ].join('.')
      versions[:new][:string] = [ versions[:new][:major], versions[:new][:minor], versions[:new][:patch] ].join('.')
      
      notify "updating version from #{versions[:old][:string]} to #{versions[:new][:string]}" do
        File.open('lib/outline.rb', 'w+') { |f| f.print data.gsub(VERSION_REGEXP, "VERSION = '#{versions[:new][:string]}'") }
        Outline::VERSION.replace(versions[:new][:string])
      end
      
      Rake::Task["version:update_file"].execute
    end
    
    desc 'Bump the patch version'
    task :patch do
      data = File.read('lib/outline.rb')
      
      versions = { old: {}, new: {} }
      versions[:old][:major], versions[:old][:minor], versions[:old][:patch] = data.match(VERSION_REGEXP).captures[1..-1].collect { |i| i.to_i }
      versions[:new] = versions[:old].dup
      versions[:new][:patch] += 1
      versions[:old][:string] = [ versions[:old][:major], versions[:old][:minor], versions[:old][:patch] ].join('.')
      versions[:new][:string] = [ versions[:new][:major], versions[:new][:minor], versions[:new][:patch] ].join('.')
      
      notify "updating version from #{versions[:old][:string]} to #{versions[:new][:string]}" do
        File.open('lib/outline.rb', 'w+') { |f| f.print data.gsub(VERSION_REGEXP, "VERSION = '#{versions[:new][:string]}'") }
        Outline::VERSION.replace(versions[:new][:string])
      end
      
      Rake::Task["version:update_file"].execute
    end
  end
end

namespace :gem do
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
  task deploy: [:build, :push, :move]
end

desc "Run all specs"
task :spec do
  sh 'bundle exec rspec spec'
end