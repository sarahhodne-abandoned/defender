module Defender
  ##
  # Include this in your ActiveModel-supporting model to enable spam
  # filtering.
  #
  # Defender will try to autodetect details about your rails setup, but you
  # need to do some configuration yourself. If you already have an application
  # config file that loads into a constant named APP_CONFIG, and your
  # comment model has an attribute named 'body', 'content' or 'comment'
  # including the comment body, then you are almost ready to go. Create the
  # 'spam' and 'defensio_sig' attribute in the database (a boolean and a
  # string, respectively) and then include {Defender::Spammable} in your
  # model. You can now call #spam? on your model after saving it.
  # Congratulations!
  #
  # Defender requires the model to have callbacks, more exactly, the
  # before_save callback. Most ActiveModel-libraries should have that, so you
  # should only need to worry if you're making your own models. Just look at
  # {Defender::Test::Comment} for an example comment model.
  module Spammable
    # These are the default attribute names Defender will pull information
    # from if no other names are configured. So the content of the comment
    # will be pulled from 'body', if that attribute exists. Otherwise, it will
    # pull from 'content'. If that doesn't exist either, it will pull from
    # 'comment'. If that doesn't exist either, you should configure your own
    # name in {Defender::Spammable::ClassMethods.configure_defender}.
    DEFENSIO_KEYS = {
      'content' => [:body, :content, :comment],
      'author-name' => [:author_name, :author],
      'author-email' => [:author_email, :email],
      'author-ip' => [:author_ip, :ip],
      'author-url' => [:author_url, :url]
    }
    
    ##
    # These methods will be pulled in as class methods in your model when
    # including {Defender::Spammable}.
    module ClassMethods
      ##
      # Configure Defender by passing a set of options.
      #
      # @param [Hash] options Options for configuring Defender.
      # @option options [Hash] :keys Mapping between field names in the
      #   database and in defensio.
      # @option options [String] :api_key Your Defensio API key. Get one at
      #   defensio.com.
      # 
      def configure_defender(options)
        keys = options.delete(:keys)
        _defensio_keys.merge!(keys) unless keys.nil?
        api_key = options.delete(:api_key)
        Defender.api_key = api_key unless api_key.nil?
      end
      
      ##
      # Returns the key-attribute mapping used.
      #
      # Will automatically set it to the defaults in {DEFENSIO_KEYS} if
      # nothing else has been set before.
      def _defensio_keys
        @_defensio_keys ||= DEFENSIO_KEYS.dup
      end
    end
    
    ##
    # These methods will be pulled in as instance methods in your model when
    # including {Defender::Spammable}.
    module InstanceMethods
      ##
      # Returns true if the comment is recognized as spam or malicious.
      #
      # If the value is stored in the database that value will be returned.
      # If nil is returned, the comment has not yet been submitted to
      # Defensio.
      #
      # @raise [Defender::DefenderError] Raised if there is no spam attribute
      #   in the model.
      # @return [Boolean] Whether the comment is spam or not.
      def spam?
        if self.new_record?
          nil
        elsif self.respond_to?(:spam) && !self.spam.nil?
          return self.spam
        else
          raise Defender::DefenderError, 'You need to add a spam attribute to the model'
        end
      end
      
      ##
      # Pass in some data to be sent to defensio. You can use this method to
      # pass in more data that you don't want to save in the model.
      #
      # This can be called several times if you want to add more data or
      # update data already added (using the same key twice will overwrite).
      #
      # Returns the data to be sent. Pass without a parameter to not modify
      # the data.
      #
      # @param [Hash<String => Object>] data The data to send to defensio. See
      #   the README for the possible key values.
      def defensio_data(data={})
        @_defensio_data ||= {}
        @_defensio_data.merge!(data)
        @_defensio_data
      end
      
      private
      
      ##
      # The callback that will be run before a document is saved.
      #
      # This will gather all the data and send it off to Defensio, and then
      # set the spam and defensio_sig attributes (and spaminess if it's
      # defined) before the model will be saved.
      #
      # @raise Defender::DefenderError If Defensio returns an error.
      def _defender_before_save
        data = {}
        _defensio_keys.each do |key, names|
          next if names.nil?
          data[key] = _pick_attribute(names)
        end
        data.merge!({
          'platform' => 'ruby',
          'type' => 'comment'
        })
        data.merge!(defensio_data) if defined?(@_defensio_data)
        document = Defender.defensio.post_document(data).last
        if document['status'] == 'failed'
          raise DefenderError, document['message']
        end
        self.spam = !document['allow'] 
        self.defensio_sig = document['signature'].to_s
        self.spaminess = document['spaminess'] if self.respond_to?(:spaminess=)
      end
      
      ##
      # Return the first attribute value from a list of attribute names/
      #
      # @param [Array<Symbol>, Symbol] names A list of attribute names
      # @return [] The attribute value of the first existing attribute
      # @return [nil] If no attribute was found (or if attribute value is nil)
      def _pick_attribute(names)
        [names].flatten.each do |name|
          return self.send(name) if self.respond_to?(name)
        end
        return nil
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
      
      ##
      # Wrapper for {Defender::Spammable::ClassMethods._defensio_keys}.
      #
      # @see Defender::Spammable::ClassMethods._defensio_keys
      def _defensio_keys
        self.class._defensio_keys
      end
    end
    
    ##
    # Includes {Defender::Spammable::ClassMethods} and
    # {Defender::Spammable::InstanceMethods} and sets up save callback.
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :before_save, :_defender_before_save
    end
  end
end