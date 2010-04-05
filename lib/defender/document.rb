module Defender
  class Document
    ##
    # Whether the document should be published on your Web site or not.
    #
    # For example, spam and malicious content are not allowed.
    #
    # @return [Boolean]
    attr_accessor :allow
    alias_method :allow?, :allow

    attr_reader :data

    ##
    # A unique identifier for the document.
    #
    # This is needed to retrieve the status back from Defensio and to submit
    # false negatives/positives to Defensio. Signatures should be kept private
    # and never shared with your users.
    #
    # @return [String]
    attr_reader :signature

    ##
    # Retrieves the status of a document back from Defensio.
    #
    # Please note that this only retrieves the status of the document (like
    # it's spaminess, whether it should be allowed or not, etc.) and not the
    # content of the request (all of the data in the {#data} hash).
    #
    # @param [String] signature The signature of the document to retrieve
    # @return [Document] The document to retrieve
    def self.find(signature)
      document = new
      _code, data = Defender.defensio.get_document(signature)
      document.instance_variable_set(:@saved, true)
      document.instance_variable_set(:@allow, data['allow'])
      document.instance_variable_set(:@signature, signature)

      document
    end

    ##
    # Initializes a new document
    def initialize
      @data = {}
      @saved = false
    end

    ##
    # @return [Boolean] Has the document been submitted to Defensio?
    def saved?
      @saved
    end

    ##
    # Submit the document to Defensio.
    #
    # This will send all of the {#data} if the document hasn't been saved
    # before. If it has been saved, it will submit whether the document was a
    # false positive/negative (set the {#allow} param before saving to do
    # this).
    #
    # @see #saved?
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
