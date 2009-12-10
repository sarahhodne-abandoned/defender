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
    # Retrieves a document from the Defensio server.
    #
    # This can be called up to 30 days after the initial posting of a document
    # to Defensio.
    #
    # @return [Document]
    def self.find(signature)
      document = new()
      code, response = Defensio.get(Defensio.uri("/documents/#{signature}"))
      case code
      when 200
        document.set_attributes(response)
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
    # Post the document to Defensio to be analyzed for spam and malicious
    # content.
    #
    # @param [Boolean] async Whether or not the document analysis should be done
    #   asynchronously. With asynchronous document analysis you will obtain
    #   better accuracy. Do not poll the servers more than once every 30 seconds
    #   for each document. To avoid polling, set the callback URL with
    #   {Defender.async_callback}. You can get the information from the server
    #   using the {#refresh} method or calling {Document.find} with the
    #   signature.
    #
    # @todo Implement asynchronous calls.
    #
    # @raise ArgumentError if a required field is not set.
    # @raise StandardError if the server says something went wrong.
    # @return [true] Returns true if everything went ok, raises an error
    #   otherwise.
    def save(async=false)
      if @signature # The document is submitted to Defensio
        code, response = Defender.put("/documents/#{@signature}", {'allow' => @allow})
        if code == 200
          set_attributes(response)
          return true
        else
          raise StandardError, response['message']
        end
      else
        @options = {}
        @options['client'] = "Defender | 0.2 | Henrik Hodne | henrik.hodne@binaryhex.com"
        @options['content'] = @content || raise(ArgumentError, "The content field is required")
        @options['platform'] = @platform || "ruby"
        @options['type'] = @type || raise(ArgumentError, "The type field is required")
        # TODO: Make this nasty block nicer
        @options['author-email'] = @author_email if @author_email
        @options['author-ip'] = @author_ip if @author_ip
        @options['author-logged-in'] = @author_logged_in if @author_logged_in
        @options['author-name'] = @author_name if @author_name
        @options['author-openid'] = @author_openid if @author_openid
        @options['author-trusted'] = @author_trusted if @author_trusted
        @options['author-url'] = @author_url if @author_url
        @options['browser-cookies'] = @browser_cookies if @browser_cookies
        @options['browser-javascript'] = @browser_javascript if @browser_javascript
        @options['document-permalink'] = @document_permalink if @document_permalink
        if @http_headers
          @options['http-headers'] = ""
          @http_headers.to_a.each do |kv|
            if kv.respond_to?(:join)
              kv = kv.join(": ")
            end
            @options['http-headers'] << kv + "\n"
          end
        end
        @options['parent-document-date'] = @parent_document_date.respond_to?(:strftime) ?
          @parent_document_date.strftime("%Y-%m-%d") :
          @parent_document_date if @parent_document_date
        @options['parent-document-permalink'] = @parent_document_permalink if @parent_document_permalink
        @options['referrer'] = @referrer if @referrer
        @options['title'] = @title if @title

        code, response = Defender.post("/documents", @options)
        if code == 200
          set_attributes(response)
          return true
        else
          raise StandardError, response['message']
        end
      end
    end

    def set_attributes(attributes)
    end
  end
end
