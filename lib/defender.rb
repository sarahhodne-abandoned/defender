require 'defensio'

require 'defender/document'

module Defender
  class << self
    attr_accessor :api_key
    attr_accessor :defensio
  end

  def self.defensio
    @defensio ||= Defensio.new(Defender.api_key)
  end
end
