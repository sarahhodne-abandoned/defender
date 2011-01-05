# -*- encoding: utf-8 -*-
require File.expand_path("../lib/defender/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "defender"
  s.version     = Defender::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Henrik Hodne']
  s.email       = ['dvyjones@dvyjones.com']
  s.homepage    = 'http://rubygems.org/gems/dvyjones'
  s.summary     = 'ActiveModel plugin for Defensio.'
  s.description = 'An ActiveModel plugin for Defensio.'
  
  s.add_dependency('defensio', '~> 0.9.1')
  s.add_dependency('activemodel', '~> 3.0.0')
  s.add_development_dependency('bundler', '~> 1.0.0')
  
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end