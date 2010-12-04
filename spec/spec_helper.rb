require 'defender'
require 'defender/test/comment'
require 'fake_defensio'

Comment = Defender::Test::Comment

Defender.defensio = FakeDefensio.new