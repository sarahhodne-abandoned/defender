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
