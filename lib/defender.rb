require 'defender/version'
require 'defender/document'

module Defender
  ##
  # You most probably don't need to set this.  It is used to replace the backend
  # when running the tests.  If you for any reason need to use another backend
  # than the defensio gem, set this.  The object needs to respond to the same
  # methods as the {Defensio} object does.
  #
  # @param [Defensio] defensio The Defensio backend
  def self.defensio=(defensio)
    @defensio = defensio
  end

  ##
  # The Defensio backend. If no backend has been set yet, this will create one
  # with the api key set with {Defender.api_key}.
  def self.defensio
    return @defensio  if defined?(@defensio)
    require 'defensio'
    @defensio ||= Defensio.new(Defender.api_key, "Defender | #{VERSION} | Henrik Hodne | dvyjones@binaryhex.com")
  end
end
