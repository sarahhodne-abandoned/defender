module Defender
  ##
  # A document contains content to be analyzed by Defensio, or that has been
  # analyzed.
  #
  # Most of the Defensio API revolves around documents, including the detection
  # of unwanted content.
  class Document
    ##
    # Whether the document should be published by your Web site or not. For
    # example, spam and malicious content are not allowed.
    #
    # This is the only attribute that can be updated after the initial saving.
    # Use this for retraining purposes.
    #
    # @return [Boolean]
    attr_accessor :allow
    alias :allow? :allow

    ##
    # The type of content in the document.
    #
    # @return [String] The possible values are innocent, spam and malicious.
    attr_reader :classification

    ##
    # Whether the document matches profanity or other words defined by the
    # user. For example, this is useful to detect obscene comments posted
    # to your Web site. When true, you can obtain a filtered version of the
    # document by calling {#filter!}.
    #
    # @return [Boolean]
    attr_reader :profane
    alias :profane? :profane

    ##
    # A unique identifier for the document. You need this value to perform new
    # requests on the same document. Signatures should be kept private and never
    # be shared with your users.
    #
    # @return [String]
    attr_reader :signature

    ##
    # A numeric value indicating how strongly the document resembles spam. For
    # example, a document containing many links to pharmaceutical sites is
    # likely to have a very high spaminess value. This value should only be used
    # for sorting, and should never be used to determine if a document should be
    # allowed or not. Spaminess should be kept private and never be shared with
    # your users.
    #
    # @return [Float<0..1>] A float value between 0 and 1, whith 1 being
    #   extremely spammy. For example, 0.89 (89%).
    attr_reader :spaminess

    ##
    # The string containing the body of the document. This field is required.
    #
    # @return [String]
    attr_accessor :content

    ##
    # The platform which the document is submitted on.
    #
    # One word, lower case. Spaces should be converted to underscores.
    #
    # *Examples:*
    # wordpress, pixelpost, drupal, phpbb, movable_type
    #
    # The default is 'ruby'.
    #
    # @return [String]
    attr_accessor :platform

    ##
    # Identified the type of content to be analyzed.
    #
    # Use *test* only for testing purposes.
    #
    # When *type* is set to *test*, Defensio (not Defender) parses content for
    # classification and spaminess. For example, if you want the API to return
    # *malicious* as the classification and a spaminess of *0.99*, insert the
    # following in content:
    #   [malicious,0.99]
    #
    # There are three possible classifications:
    #
    # * innocent
    # * spam
    # * malicious
    #
    # Spaminess should be a decimal value between 0 and 1 (see
    # {#spaminess})
    #
    # *IMPORTANT*
    #
    # Do *NOT* leave type set to *test* in production. This could represent a
    # significant security breach.
    attr_accessor :type

    ##
    # The email address of the author of the document.
    #
    # @return [String]
    attr_accessor :author_email

    ##
    # The IP address of the author of the document.
    #
    # For example, this could be the IP address of the person posting a comment
    # on a blog.
    #
    # @return [String]
    attr_accessor :author_ip

    ##
    # Whether or not the user posting the document is logged in onto your Web
    # site, either through your own authentication mechanism or through OpenID.
    #
    # @see Document#author_openid
    # @see Document#author_trusted
    # @return [Boolean]
    attr_accessor :author_logged_in

    ##
    # The name of the author of the document.
    #
    # @return [Boolean]
    attr_accessor :author_name

    ##
    # The OpenID URL of the logged-on user. Must be used in conjunction with
    # {Document#author_logged_in} = true.
    #
    # OpenID authentication must be taken care of by your application. Only send
    # this parameter if you have successfully authenticated the user with
    # OpenID.
    #
    # @return [String]
    attr_accessor :author_openid

    ##
    # Whether or not the user is an administrator, moderator or editor of your
    # Web site. Pass `true` only if you can guarantee that the user has been
    # authenticated, has a role of responsibility, and can be trusted as a good
    # Web citizen.
    #
    # @return [Boolean]
    attr_accessor :author_trusted

    ##
    # The URL of the person posting the document.
    #
    # @return [String]
    attr_accessor :author_url

    ##
    # Whether or not the Web browser used to post the document (i.e., the
    # comment) has cookies enabled. If no such detection has been made, leave
    # this value empty.
    #
    # @return [Boolean]
    attr_accessor :browser_cookies

    ##
    # Whether or not the Web browser used to post the document (i.e., the
    # comment) has JavaScript enabled. If no such detection has been made, leave
    # this value empty.
    #
    # @return [Boolean]
    attr_accessor :browser_javascript

    ##
    # The URL of the document being posted.
    #
    # *Examples*
    #
    # For a comment on a blog, the permalink URL might be:
    #
    #   'http://yourdomain.com/article#comment-51'
    #
    # For an article, it might be:
    #
    #   'http://yourdomain.com/article'
    #
    # @return [String]
    attr_accessor :document_permalink

    ##
    # Contains the HTTP headers sent with the request. You can send a few values
    # or all values. Because this information helps Defensio determine if a
    # document is innocent or not, the more headers you send, the better.
    #
    # @see #referrer
    # @return [Hash{String => String}, Array<String>] You can pass a hash with
    #   key => values, or an array where each entry has the format `"HEADER:
    #   value"`
    attr_accessor :http_headers

    ##
    # The date the parent document was posted. For example, on a blog, this
    # would be the date the article related to the comment (document) was
    # posted.
    #
    # If you are using threaded comments, send the date the article was posted,
    # *not* the date the parent comment was posted.
    #
    # @return [Time, Date, DateTime, "yyyy-mm-dd"] If a Time or DateTime is passed, only the
    #   date part will be saved.
    attr_accessor :parent_document_date

    ##
    # The URL of the parent document. For example, on a blog, this would be the
    # URL of the article on which the comment (document) was posted.
    #
    # @see #document_permalink
    # @return [String]
    attr_accessor :parent_document_permalink

    ##
    # Provide the value of the HTTP_REFERER (note the spelling) in this field.
    #
    # @see #http_headers
    # @return [String]
    attr_accessor :referrer

    ##
    # Provide the title of the document being sent. For example, this might be
    # the title of a blog article.
    #
    # Do not send this information if no title has been provided.
    attr_accessor :title

    ##
    # Is the document still pending?
    #
    # @return [Boolean]
    attr_reader :pending
    alias :pending? :pending

    ##
    # Set the pending attribute to true. Only to be used by {find} and similar
    # methods.
    #
    # @private
    def pending!; @pending = true; end

    ##
    # Retrieves a document from the Defensio server.
    #
    # This can be called up to 30 days after the initial posting of a document
    # to Defensio.
    #
    # @return [Document]
    def self.find(signature)
      document = new()
      response = Defender.get("/#{Defender.api_key}/documents/#{signature}.json")['defensio-result']
      if response['status'] == 'success' || response['status'] == 'pending'
        document.set_attributes(response)
        document.pending! if response['status'] == 'pending'
      else
        raise StandardError, response['message']
      end
      document
    end

    ##
    # Create a new document.
    def initialize()
    end

    ##
    # Re-retrieves the document from the Defensio server
    #
    # This can be called up to 30 days after the initial posting of the document
    # to Defensio
    #
    # @return [true] The document was updated.
    # @return [false] The document was not updated (still pending).
    def refresh!
      response = Defender.get("/#{Defender.api_key}/documents/#{signature}.json")['defensio-result']
      if response['status'] == 'success'
        document.set_attributes(response)
        return true
      elsif response['status'] == 'pending'
        pending!
        return false
      else
        raise StandardError, response['message']
      end
    end

    ##
    # Creates an attributes hash to be sent to Defensio. This method will make
    # sure that the required attributess are in, and the names of the attributes
    # are correct.
    #
    # @return [Hash{String => String}]
    def attributes_hash
      options = {
        'client' => "Defender | #{Defender::VERSION} | Henrik Hodne | henrik.hodne@binaryhex.com",
        'platform' => platform || "ruby",
        'content' => content,
        'type' => type
      }
      [
        :author_email, :author_ip, :author_logged_in, :author_name, :author_openid,
        :author_trusted, :author_url, :browser_cookies, :browser_javascript,
        :document_permalink, :referrer, :title, :parent_document_permalink
      ].each do |symbol|
        options[symbol.to_s.gsub("_", "-")] = self.send(symbol)
      end

      headers = http_headers
      unless headers.nil?
        options['http-headers'] = headers.to_a.map do |kv|
          kv.respond_to?(:join) ? kv.join(": ") : kv
        end.join("\n")
      end

      pddate = parent_document_date
      options['parent-document-date'] = pddate.respond_to?(:strftime) ?
        pddate.strftime("%Y-%m-%d") : pddate

      formatted_options = {}

      options.each do |key, value|
        formatted_options[key] = value.to_s unless value.nil?
      end

      formatted_options
    end

    ##
    # Post the document to Defensio to be analyzed for spam and malicious
    # content.
    #
    # @param [Boolean] async Whether or not the document analysis should be done
    #   asynchronously. With asynchronous document analysis you will obtain
    #   better accuracy. Do not poll the servers more than once every 30 seconds
    #   for each document. To avoid polling, set the callback URL with
    #   {Defender.async_callback}. You can get the information from the server
    #   using the {#refresh!} method or calling {Document.find} with the
    #   signature.
    #
    # @see #pending?
    #
    # @raise ArgumentError if a required field is not set.
    # @return [Boolean] Whether the record was saved or not.
    def save(async=false)
      if sig = signature # The document is submitted to Defensio
        response = Defender.put("/#{Defender.api_key}/documents/#{sig}.json",
                                :body => { :allow => allow? })['defensio-result']
      else
        hsh = attributes_hash
        if attributes_hash['content'].nil?
          raise ArgumentError, 'The content field is required'
        end
        if attributes_hash['type'].nil?
          raise ArgumentError, 'The type field is required'
        end

        if async
          hsh['async'] = 'true'
          hsh['async-callback'] = Defender.async_callback if Defender.async_callback
        end
        response = Defender.post("/#{Defender.api_key}/documents.json", :body => hsh)['defensio-result']
      end
      if response['status'] == 'success'
        set_attributes(response)
        return true
      elsif response['status'] == 'pending'
        set_attributes(response) # Some fields are blank
        @pending = true
        return true
      else
        return false
      end
    end

    def set_attributes(attributes)
      [:classification, :signature, :spaminess, :allow].each do |symbol|
        self.instance_variable_set(:"@#{symbol}", attributes[symbol.to_s])
      end
      @profane = attributes['profanity-match']
      undefine_setters
    end

    ##
    # Filters the provided fields. The filtering is based on a default
    # dictionary and one previously configured by the user.
    #
    # @param [Array<Symbol>] *args The fields to filter (like `:content`,
    #   `:author_name`, etc.)
    def filter!(*args)
      filter = {}
      args.each {|arg| filter[arg] = __send__(arg) }
      response = Defender.post("/#{Defender.api_key}/profanity-filter.json", filter)['defensio-result']
      if response['status'] == 'success'
        response['filtered'].each do |key, value|
          self.instance_variable_set(:"@#{key}", value)
        end
      else
        raise StandardError, response['message']
      end
    end

    private

    def undefine_setters
      [
        :content=, :platform=, :type=, :author_email=, :author_ip=,
        :author_logged_in=, :author_name=, :author_openid=,
        :author_trusted=, :author_url=, :browser_cookies=,
        :browser_javascript=, :document_permalink=, :http_headers=,
        :parent_document_date=, :referrer=, :title=
      ].each do |method|
        # TODO: Fix hack.
        instance_eval "def self.#{method}(*args)\nmethod_missing(#{method.inspect}, *args)\nend"
      end
    end
  end
end
