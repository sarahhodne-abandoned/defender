# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'defender/version'

Gem::Specification.new do |s|
  s.name = 'defender'
  s.version = Defender::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Henrik Hodne']
  s.email = ['henrik.hodne@binaryhex.com']
  s.homepage = 'http://github.com/dvyjones/defender'
  s.summary = 'Ruby API wrapper for Defensio'
  s.description = 'A wrapper of the Defensio spam filtering service.'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency('defensio', '~> 0.9.1')
  s.add_development_dependency('bundler', '~> 1.0.2')
  
  s.files = Dir.glob('{bin,lib}/**/*') + %w(LICENSE README.md)
  s.require_path = 'lib'
end
