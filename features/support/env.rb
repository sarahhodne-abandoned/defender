$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'defender'
require 'defender/test/comment'

Comment = Defender::Test::Comment

require 'cucumber/rspec/doubles'
require File.expand_path('../../../spec/fake_defensio', __FILE__)
