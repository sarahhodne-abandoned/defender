module Defender
  module Spammable
    DEFENSIO_KEYS = {
      'content' => [:body, :content, :comment],
      'author-name' => [:author_name, :author]
    }
    
    module ClassMethods
      
    end
    
    module InstanceMethods
      ##
      # Returns true if the comment is recognized as spam or malicious.
      #
      # If the value is stored in the database that value will be returned.
      # Otherwise, the value will be retrieved from Defensio. If nil is
      # returned, the comment has not yet been submitted to Defensio.
      def spam?
        if self.new_record?
          nil
        elsif self.respond_to?(:spam) && !self.spam.nil?
          return self.spam
        else
          raise Defender::DefenderError, 'You need to add a spam attribute to the model'
        end
      end
      
      private
      
      def _defender_before_save
        data = {}
        DEFENSIO_KEYS.each do |key, names|
          data[key] = _pick_attribute_name(names)
        end
        document = Defender.defensio.post_document(data).last
        self.spam = !document['allow'] 
        self.defensio_sig = document['signature']
        self.spaminess = document['spaminess'] if self.respond_to?(:spaminess=)
      end
      
      def _pick_attribute_name(names)
        names.each do |name|
          return self.send(name) if self.respond_to?(name)
        end
      end
      
      ##
      # Retrieves the Defensio document from the server if it hasn't been
      # retrieved before or if the first parameter is true.
      #
      # @param [Boolean] force Pass true to force a refetch, otherwise it will
      #   get the cached document (if one is cached).
      # @return [Hash] The document retrieved from the server.
      def _get_defensio_document(force=false)
        if force || @_defensio_document.nil?
          @_defensio_document = Defender.defensio.get_document(self.defensio_sig).last
        end
        @_defensio_document
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :before_save, :_defender_before_save
    end
  end
end