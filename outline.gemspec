$:.unshift( File.expand_path("../lib", __FILE__) )
PROJECT_NAME ||= File.basename(__FILE__, ".gemspec")
require "#{PROJECT_NAME}/version"

Gem::Specification.new do |s|
  s.author = "Ryan Scott Lewis"
  s.email = "c00lryguy@gmail.com"
  
  s.name = PROJECT_NAME
  s.description = "Easily set configurations on your Ruby apps."
  s.summary = "Simplify your configurations."
  s.homepage = "http://github.com/c00lryguy/#{PROJECT_NAME}"
  s.version = Outline::VERSION
  s.license = 'MIT'
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  
  s.files = Dir['{{Rake,Gem}file{.lock,},README*,VERSION,LICENSE,*.gemspec,{bin,examples,lib,spec,test}/**/*}']
  s.test_files = Dir['{examples,spec,test}/**/*']
  
  s.add_dependency("meta_tools", "~> 0.2.7")
  s.add_development_dependency("rspec", "~> 2.6.0")
  s.add_development_dependency("guard-rspec", "~> 0.7.0")
end
