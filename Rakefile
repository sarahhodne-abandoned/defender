# coding:utf-8
$:.unshift File.expand_path('../lib', __FILE__)

require 'bundler'
require 'rubygems'
require 'rubygems/specification'
require 'defender'

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w{-fs --color}
end

begin
  require 'yard'
rescue LoadError
  raise 'Run `gem install yard` to generate docs'
else
  YARD::Rake::YardocTask.new do |conf|
    conf.options = ['-mmarkdown', '-rREADME.markdown']
    conf.files = ['lib/**/*.rb', '-', 'LICENSE']
  end
end
