require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "defender"
    gem.summary = %Q{Ruby API wrapper for Defensio}
    gem.description = %Q{A wrapper of the Defensio spam filtering service.}
    gem.email = "henrik.hodne@binaryhex.com"
    gem.homepage = "http://github.com/dvyjones/defender"
    gem.authors = ["Henrik Hodne"]
    gem.add_dependency "defensio", "~> 0.9.1"
    gem.add_development_dependency "rspec", "~> 1.3.0"
    gem.add_development_dependency "yard", "~> 0.5.3"
    gem.add_development_dependency "mocha", "~> 0.9.8"
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |conf|
    #conf.options = ["-mmarkdown"]
    conf.files = ["lib/**/*.rb", "-", "LICENSE"]
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
