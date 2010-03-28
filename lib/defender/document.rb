module Defender
  class Document
    attr_accessor :allow
    alias :allow? :allow

    attr_reader :data
    attr_reader :signature

    def initialize
      @data = {}
      @saved = false
    end

    def saved?
      @saved
    end

    def save
      if saved?
        code, data = Defender.defensio.put_document({:allow => @allow})
      else
        code, data = Defender.defensio.post_document(@data)
        @allow = data['allow']
        @signature = data['signature']
        @saved = true
      end
    end
  end
end
