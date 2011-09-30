module Defender
  # Includes all the model magic for Defender. This module should be included in
  # your model to enable Defender on it. Defender does some automatic detection
  # on your setup, but you need to do some configuration yourself. You can set
  # the API key in two different ways. If you only use Defender on one model,
  # you can configure the API key in the model with the configure_defender
  # method. If you prefer to use initializers, or you have multiple models, you
  # probably want to define it in an initializer. You can do this by calling
  # Defender.api_key directly, like this:
  #
  #   Defender.api_key = 'This is your API key'
  #
  # Defender only requires your models to have a before_save callback, but since
  # most ActiveModel libraries should have this you only need to worry about it
  # if you're making your own models. Just have a look at
  # Defender::Test::Comment for an example comment model.
  module Spammable
    # Public: These are the default attribute names Defender will pull
    # information from if no other names are configured. So the content of the
    # comment will be pulled from 'body', if that attribute exists. Otherwise,
    # it will be pulled from 'content'. If that doesn't exist either, it will
    # pull from 'comment'. If that attribute doesn't exist either, you should
    # configure your own attributes with the configure_defender method.
    DEFENSIO_KEYS = {
      'content' => [:body, :content, :comment],
      'author-name' => [:author_name, :author],
      'author-email' => [:author_email, :email],
      'author-ip' => [:author_ip, :ip],
      'author-url' => [:author_url, :url]
    }.freeze
    
    # Public: Methods that will be included as class methods when including
    # Defender::Spammable into your model.
    module ClassMethods      
      # Public: Configures various Defender options.
      #
      # options - The hash options used to configure Defender:
      #           :keys      - A Hash which maps field names in the database to
      #                        Defensio field names (optional).
      #           :api_key   - Your Defensio API key String (optional).
      #           :test_mode - Set this to true to enable the test mode. See
      #                        Defender.test_mode for more information.
      #
      # Examples
      #
      #   configure_defender :keys => { 'content' => :comment_content },
      #     :api_key => 'Your API key.', :test_mode => true
      #
      # Returns nothing
      def configure_defender(options)
        keys = options.delete(:keys)
        _defensio_keys.merge!(keys) unless keys.nil?
        api_key = options.delete(:api_key)
        Defender.api_key = api_key unless api_key.nil?
        Defender.test_mode = options.delete(:test_mode)
      end
      
      # Deprecated: Returns whether Defender is in "test mode".
      #
      # Use Defender.test_mode instead.
      def test_mode
        Defender.test_mode
      end
      
      # Deprecated: Enables/disables Defender's test mode.
      #
      # Use Defender.test_mode= instead.
      def test_mode=(test_mode)
        Defender.test_mode = test_mode
      end
      
      # Internal: Returns the key-attribute mapping Hash used.
      #
      # This will default to DEFENSIO_KEYS, but can be modified.
      #
      # The Public API has access to this through configure_defender.
      def _defensio_keys
        @_defensio_keys ||= DEFENSIO_KEYS.dup
      end
    end
    
    # Public: Methods that will be included as instance methods when including
    # Defender::Spammable into your model.
    module InstanceMethods
      # Public: Whether the comment is recognized a malicious comment or as
      # spam.
      #
      # Returns the Boolean value stored in the database, or nil if the comment
      #   hasn't been submitted to Defensio yet.
      # Raises Defender::DefenderError if there is no spam attribute in the
      #   model.
      def spam?
        if self.new_record?
          nil
        elsif self.respond_to?(:spam) && !self.spam.nil?
          return self.spam
        else
          raise Defender::DefenderError, 'You need to add a spam attribute to the model'
        end
      end
      
      # Public: Report a false positive to Defensio and update the spam
      # attribute.
      #
      # A false positive is a legitimate comment incorrectly marked as spam.
      #
      # This must be done within 30 days of the comment originally being
      # submitted. If you need to update this after that, just set the spam
      # attribute on your model and save it.
      #
      # Raises a Defender::DefenderError if Defensio returns an error.
      def false_positive!
        document = Defender.defensio.put_document(self.defensio_sig, {'allow' => 'true'}).last
        if document['status'] == 'failed'
          raise DefenderError, document['message']
        end
        update_attributes(:spam => false)
      end
      
      # Public: Report a false negative to Defensio and update the spam
      # attribute.
      #
      # A false negative is a spammy comment incorrectly marked as legitimate.
      #
      # This must be done within 30 days of the comment originally being
      # submitted. If you need to update this after that, just set the spam
      # attribute on your model and save it.
      #
      # Raises a Defender::DefenderError if Defensio returns an error.
      def false_negative!
        document = Defender.defensio.put_document(self.defensio_sig, {'allow' => 'false'}).last
        if document['status'] == 'failed'
          raise DefenderError, document['message']
        end
        update_attributes(:spam => true)
      end
      
      # Public: Pass in more data to be sent to Defensio. You should use this
      # for data you don't want to save in the model, for instance HTTP headers.
      #
      # This can be called several times, the new data will be merged into the
      # existing data. If you use the same key twice, the new value will
      # overwrite the old.
      #
      # data - The Hash data to send to Defensio. Check the README for the
      #        possible keys.
      #
      # Examples
      #
      #   def create # A Rails controller action
      #     @comment = Comment.new(params[:comment])
      #     @comment.defensio_data(
      #       'http-headers' => request.env.map {|k,v| "#{k}: #{v}" }.join("\n")
      #     )
      #   end
      #
      # Returns the data to be sent.
      def defensio_data(data={})
        @_defensio_data ||= {}
        @_defensio_data.merge!(data)
        @_defensio_data
      end
      
      private
      
      # Internal: The callback that will be run before a document is created..
      #
      # This will gather all the data and send it off to Defensio, and then set
      # the spam and defensio_sig attributes (and spaminess if it's defined)
      # before the model will be saved.
      #
      # Raises a Defender::DefenderError if Defensio returns an error. Please
      #   note that this will cancel the save.
      def _defender_before_create
        data = {}
        _defensio_keys.each do |key, names|
          next if names.nil?
          data[key] = _pick_attribute(names)
        end
        data.merge!({
          'platform' => 'ruby',
          'type' => (Defender.test_mode ? 'test' : 'comment')
        })
        data.merge!(defensio_data) if defined?(@_defensio_data)
        document = Defender.defensio.post_document(data).last
        if document['status'] == 'failed'
          raise DefenderError, document['message']
        end
        self.spam = !document['allow'] 
        self.defensio_sig = document['signature'].to_s
        self.spaminess = document['spaminess'] if self.respond_to?(:spaminess=)
        true
      end
      
      # Internal: Returns value of the first attribute that exists in a list of
      # attributes.
      #
      # names - A Symbol or Array of Symbols representing the attribute name(s).
      def _pick_attribute(names)
        [names].flatten.each do |name|
          return self.send(name) if self.respond_to?(name)
        end
        return nil
      end
      
      # Internal: Retrieves the Defensio document from the server if it hasn't
      # been retrieved before or if the first parameter is true.
      #
      # force - A Boolean representing whether to force a refetch. If a refetch
      #         isn't forced, the document will only be fetched if it hasn't
      #         been fetched already.
      #
      # Returns the Hash with the information retrieved from the server.
      def _get_defensio_document(force=false)
        if force || @_defensio_document.nil?
          @_defensio_document = Defender.defensio.get_document(self.defensio_sig).last
        end
        @_defensio_document
      end
      
      # Internal: Wrapper for the class method with the same name.
      def _defensio_keys
        self.class._defensio_keys
      end
    end
    
    # Internal: Includes the ClassMethods and InstanceMethods and sets up the
    # before_save callback.
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :before_create, :_defender_before_create
    end
  end
end