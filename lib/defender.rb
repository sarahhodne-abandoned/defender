require 'defender/version'
require 'defender/document'

module Defender
  ##
  # Set this to your Defensio API key. Get one at http://defensio.com.
  def self.api_key=(api_key)
    @api_key = api_key.to_s
  end

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
    @defensio ||= Defensio.new(@api_key, "Defender | #{VERSION} | Henrik Hodne | dvyjones@binaryhex.com")
  end

  ##
  # Calls a defensio method and wraps in error handling.
  #
  # Returns false if the method failed, otherwise returns whatever the method returns
  #
  # @param [Symbol] method Which method to call.
  # @return [false, Array(Fixnum, Hash)]
  def self.call(method, *args)
    code, data = defensio.send(method, *args)
    if code == 200 && data['status'] == 'success'
      [code, data]
    else
      false
    end
  end
end
