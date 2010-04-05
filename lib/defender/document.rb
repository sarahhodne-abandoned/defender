module Defender
  class Document
    attr_accessor :allow
    alias_method :allow?, :allow

    attr_reader :data
    attr_reader :signature

    def self.find(signature)
      document = new
      _code, data = Defender.defensio.get_document(signature)
      document.instance_variable_set(:@saved, true)
      document.instance_variable_set(:@allow, data['allow'])
      document.instance_variable_set(:@signature, signature)

      document
    end

    def initialize
      @data = {}
      @saved = false
    end

    def saved?
      @saved
    end

    def save
      if saved?
        _code, data = Defender.defensio.put_document(@signature, {:allow => @allow})
      else
        _code, data = Defender.defensio.post_document(@data)
        @allow = data['allow']
        @signature = data['signature']
        @saved = true
      end
    end
  end
end
