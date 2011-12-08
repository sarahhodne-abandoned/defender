require 'defender/model'

# Public: The main Defender module. This is the namespace under which all of
# Defender is.
module Defender
  autoload :VERSION, 'defender/version'
  autoload :Version, 'defender/version'
  autoload :Spammable, 'defender/spammable'
  autoload :DefenderError, 'defender/defender_error'

  # Public: Set the Defensio API key. Get one at http://defensio.com.
  #
  # Defender will not work without a Defensio API key.
  #
  # Returns the Defensio API key string.
  def self.api_key=(api_key)
    @api_key = api_key.to_s
  end

  # Public: Returns the Defensio API key String set with #api_key=
  def self.api_key
    @api_key
  end

  # Public: Returns whether Defender is in "test mode".
  #
  # When in test mode, you can specify what kind of response you want in the
  # content field. If you want a comment to be marked as spam with a
  # spaminess of 0.85, you write [spam,0.85] somewhere in the content field
  # of the document. If you want a malicious response with a spaminess of
  # 0.99 you write [malicious,0.99], and for an innocent response you write
  # [innocent,0.25]. This is the preferred way of testing, and if you test
  # by writing "spammy" comments, you might hurt the Defensio performance.
  def self.test_mode
    !!@test_mode
  end

  # Public: Enables/disables Defender's test mode. You can use this, or the
  # configure_defender method to enable the test mode, but you should
  # probably use this if you only temporarily want to enable the test mode.
  def self.test_mode=(test_mode)
    @test_mode = test_mode
  end

  # Internal: This is for replacing the Defensio backend when running tests.
  def self.defensio=(defensio)
    @defensio = defensio
  end

  # Internal: The Defensio backend. If no backend has been set yet, this will
  # create one with the API key set with #api_key=.
  #
  # Returns the Defensio backend.
  def self.defensio
    return @defensio  if defined?(@defensio)
    require 'defensio'
    @defensio ||= Defensio.new(@api_key, "Defender | #{VERSION} | Henrik Hodne | dvyjones@binaryhex.com")
  end
end
