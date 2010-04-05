# coding:utf-8
$:.unshift File.expand_path('../lib', __FILE__)

require 'rubygems'
require 'rubygems/specification'
require 'defender'

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../defender.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

begin
  require 'spec/rake/spectask'
rescue LoadError
  raise 'Run `gem install rspec` to be able to run specs'
else
  desc 'Run specs'
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(-fs --color)
    t.warning = true
  end
end

begin
  require 'cucumber/rake/task'
rescue LoadError
  raise 'Run `gem install cucumber` to be able to run features'
else
  Cucumber::Rake::Task.new
end

desc 'Run features and specs (CI task)'
task :ci => [:features, :spec]

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

begin
  require 'rake/gempackagetask'
rescue LoadError
  task(:gem) { $stderr.puts '`gem install rake` to package gems' }
else
  Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.gem_spec = gemspec
  end
  task :gem => :gemspec
end

desc 'Install the gem locally'
task :install => :package do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

desc 'validate the gemspec'
task :gemspec do
  gemspec.validate
end

task :package => :gemspec
task :default => :spec
