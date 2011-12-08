require File.expand_path("../lib/defender/version", __FILE__)

Gem::Specification.new do |s|
  s.name = 'defender'
  s.version = Defender::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'ActiveModel plugin for Defensio.'
  s.homepage = 'http://github.com/dvyjones/defender'
  s.authors = ['Henrik Hodne']
  s.email = ['dvyjones@dvyjones.com']

  s.files = %w(README.md Rakefile LICENSE)

  s.add_dependency 'defensio', '~> 0.9.1'
  s.add_dependency 'activemodel', '>= 3.0.0'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'

  s.description = <<desc
  Defender is a wrapper for the Defensio spam filtering API. From their own
  site:

  More than just another spam filter, Defensio also eliminates malware and other
  unwanted or risky content to fully protect your blog or Web 2.0 application.
desc
end
