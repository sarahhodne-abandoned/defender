require File.expand_path("../lib/defender/version", __FILE__)

Gem::Specification.new do |s|
  s.name = 'defender'
  s.version = Defender::VERSION
  s.summary = 'ActiveModel plugin for Defensio.'
  s.authors = ['Henrik Hodne']
  s.email = ['dvyjones@dvyjones.com']
  
  s.files = Dir['lib/**/*']
  
  s.add_dependency 'defensio', '~> 0.9.1'
  s.add_dependency 'activemodel', '~> 3.0.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
end
