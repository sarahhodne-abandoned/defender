module Defender
  ##
  # Include this in your ActiveModel-supporting model to enable spam
  # filtering.
  #
  # Defender will try to autodetect details about your rails setup, but you
  # need to do some configuration yourself. If you already have an application
  # config file that loads into a constant named {APP_CONFIG}, and your
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
  #
  # @author Henrik Hodne
  module Spammable
    # These are the default attribute names Defender will pull information
    # from if no other names are configured. So the content of the comment
    # will be pulled from 'body', if that attribute exists. Otherwise, it will
    # pull from 'content'. If that doesn't exist either, it will pull from
    # 'comment'. If that doesn't exist either, you should configure your own
    # name in {Spammable::ClassMethods.configure_defender}.
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
      # Configure defender by passing a set of options.
      #
      # 
      def self.configure_defender(options)
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
      
      private
      
      def _defender_before_save
        data = {}
        DEFENSIO_KEYS.each do |key, names|
          data[key] = _pick_attribute_name(names)
        end
        data.merge({
          'platform' => 'ruby',
          'type' => 'comment'
        })
        document = Defender.defensio.post_document(data).last
        self.spam = !document['allow'] 
        self.defensio_sig = document['signature'].to_s
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