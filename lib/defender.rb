require 'yaml'
require 'net/http'

class Defender
  # The Defensio API version currently supported by Defender
  API_VERSION = "1.2"
  
  DEFAULT_OPTIONS = {
    service_type: "blog",
    api_key: "",
    owner_url: ""
  }
  
  ##
  # Raised if an invalid or no API key is given
  class APIKeyError < StandardError; end
  
  ##
  # The response from the {Defender#audit_comment} method. Should only be
  # initialized by the library.
  class CommentResponse
    ##
    # A message signature that uniquely identifies the comment in the Defensio
    # system. This signature should be stored by the client for retraining
    # purposes.
    attr_reader :signature
    
    ##
    # A value indicating the relative likelihood of the comment being spam.
    # This value should be stored by the client for use in building convenient
    # spam sorting user-interfaces.
    #
    # @return [Float] A value between 0 and 1.
    attr_reader :spaminess
    
    ##
    # Initialize a CommentResponse. Should only be called by the library.
    #
    # @param [Hash] response The response from the audit-comment call.
    def initialize(response)
      @signature = response["signature"]
      @spam = response["spam"]
      @spaminess = response["spaminess"].to_f
    end
    
    ##
    # Returns true if Defensio marked the comment as spam, returns false
    # otherwise.
    #
    # @return [Boolean]
    def spam?
      @spam
    end
    
    def to_s
      @signature
    end
  end
  
  ##
  # The response from the {Defender#statistics} method. Should only be
  # initialized by the library.
  class Statistics
    ##
    # Describes the percentage of comments correctly identified as spam/ham by
    # Defensio on this blog.
    #
    # @return [Float<0..1>]
    attr_reader :accuracy
    
    ##
    # The number of spam comments caught by the filter.
    attr_reader :spam
    
    ##
    # The number of ham (legitimate) comments accepted by the filter.
    attr_reader :ham
    
    ##
    # The number of times a legitimate message was retrained from the spambox
    # (i.e. "de-spammed" by the user)
    attr_reader :false_positives
    
    ##
    # The number of times a spam message was retrained from comments box (i.e.
    # "de-legitimized" by the user)
    attr_reader :false_negatives
    
    ##
    # A boolean value indicating whether Defensio is still in its initial
    # learning phase.
    #
    # @return [Boolean]
    attr_reader :learning
    
    ##
    # More details on the reason(s) why Defensio is still in its initial
    # learning phase.
    attr_reader :learning_status
    
    def initialize(response)
      @accuracy = response["accuracy"]
      @spam = response["spam"]
      @ham = response["ham"]
      @false_positives = response["false-positives"]
      @false_negatives = response["false-negatives"]
      @learning = response["learning"]
      @learning_status = response["learning-status"]
    end
  end
  
  attr_accessor :service_type, :api_key, :owner_url
  
  ##
  # Raises a StandardError with the error message from Defensio if the
  # response is a "failed" one.
  #
  # @param [Hash] response The return value from {#call_action}.
  def self.raise_if_error(response)
    if response["status"] == "fail"
      raise StandardError, response["message"]
    end
    response
  end
  
  ##
  # Converts a hash with symbol keys and underscores to a hash with string
  # keys and hyphens. Calls #strftime or #to_s on the values.
  #
  # @param [Hash] options Input options.
  # @return [Hash]
  def self.options_to_parameters(options)
    opts = {}
    options.each do |key, value|
      if value.respond_to?(:strftime)
        value = value.strftime("%Y/%m/%d")
      end
      opts[key.to_s.gsub("_", "-").downcase] = value.to_s
    end
    opts
  end

  ##
  # Initialize Defender
  #
  # @param [Hash] opts The options hash.
  # @option opts ["blog","app"] :service_type ("blog") The service type. May be
  #   "app" (use of Defender within an application) or "blog" (use of Defender
  #   to support a blogging platform).
  # @option opts [String] :api_key Your API key. This option is required, the
  #   method calls will fail without it.
  def initialize(opts={})
    opts = DEFAULT_OPTIONS.merge(opts)
    @service_type = opts[:service_type]
    @api_key = opts[:api_key]
    @owner_url = opts[:owner_url]
  end
  
  ##
  # Checks if the given key is valid.
  #
  # @return [Boolean]
  # @see http://defensio.com/api/#validate-key
  def valid_key?
    response = call_action("validate-key")
    if response["status"] == "success"
      return true
    else
      return false
    end
  end
  
  ##
  # Announce an article existence. This should (if feasible) be called when an
  # article or blogpost is created so Defensio can analyse it.
  #
  # @param [Hash] opts All options are required.
  # @option opts [#to_s] :article_title The title of the article
  # @option opts [#to_s] :article_author The name of the author of the article
  # @option opts [#to_s] :article_author_email The email address of the person posting the
  #   article.
  # @option opts [#to_s] :article_content The content of the article itself.
  # @option opts [#to_s] :permalink The permalink of the article just posted.
  # @raise [StandardError] If the call fails, a StandardError is raised with
  #   the error message given from Defensio.
  # @return [Boolean] Returns true if the article was successfully announced,
  #   raises StandardError otherwise.
  # @see http://defensio.com/api/#announce-article
  def announce_article(opts={})
    response = call_action(Defender.options_to_parameters(opts))
    true
  end
  
  ##
  # Check if a comment is spam. This is the central action of Defensio.
  #
  # @param [Hash] opts All options are recommended, but only required if noted.
  # @option opts [#to_s] :user_ip The IP address of whomever is posting the
  #   comment. This option is required.
  # @option opts [#to_s, #strftime] :article_date The date the original blog
  #   article was posted. If a string is given, it must be in the format
  #   "yyyy/mm/dd". This option is required.
  # @option opts [#to_s] :comment_author The name of the author of the comment.
  #   This option is required.
  # @option opts ["comment", "trackback", "pingback", "other"] :comment_type
  #   The type of the comment being posted to the blog. This option is required
  # @option opts [#to_s] :comment_content The actual content of the comment
  #   (strongly recommended to be included where ever possible).
  # @option opts [#to_s] :comment_author_email The email address of the person
  #   posting the comment.
  # @option opts [#to_s] :comment_author_url The URL of the person posting the
  #   comment.
  # @option opts [#to_s] :permalink The permalink of the blog post to which
  #   the comment is being posted.
  # @option opts [#to_s] :referrer The URL of the site that brought commenter
  #   to this page.
  # @option opts [Boolean] :user_logged_in Whether or not the user posting
  #   the comment is logged-into the blogging platform
  # @option opts [Boolean] :trusted_user Whether or not the user is an
  #   administrator, moderator or editor of this blog; the client should pass
  #   true only if blogging platform can guarantee that the user has been
  #   authenticated and has a role of responsibility on this blog.
  # @option opts [#to_s] :openid The OpenID URL of the currently logged in
  #   user. Must be used in conjunction with :user_logged_in => true. OpenID
  #   authentication must be taken care of by your application.
  # @option opts [#to_s] :test_force For testing purposes only: Use this
  #   parameter to force the outcome of audit_comment. Optionally affix (with
  #   a comma) a desired spaminess return value (in the range 0 to 1).
  #   Example: "spam,0.5000" or "ham,0.0010".
  # @raise [StandardError] If the call fails, a StandardError is raised with
  #   the error message given from Defensio.
  # @return [Defender::CommentResponse]
  # @see http://defensio.com/api/#audit-comment
  def audit_comment(opts={})
    response = call_action("audit-comment", Defender.options_to_parameters(opts))
    return CommentResponse.new(response)
  end
  
  ##
  # This action is used to retrain false negatives. False negatives are
  # comments that were originally tagged as "ham" (i.e. legitimate) but were
  # in fact spam.
  # 
  # @param [Array<#to_s, CommentResponse>] signatures List of signatures (may
  #   contain a single entry) of the comments to be submitted for retraining.
  #   Note that a signature for each comment was originally provided by the
  #   {#audit_comment} method.
  # @raise [StandardError] If the call fails, a StandardError is raised with
  #   the error message given from Defensio.
  # @return [Boolean] Returns true if the comments were successfully marked,
  #   raises StandardError otherwise.
  def report_false_negatives(signatures)
    response = call_action("report-false-negatives",
                           "signatures" => signatures.map(&:to_s).join(","))
    true
  end
  
  ##
  # This action is used to retrain false negatives. False negatives are
  # comments that were originally tagged as spam but were in fact "ham" (i.e.
  # legitimate).
  # 
  # @param [Array<#to_s, CommentResponse>] signatures List of signatures (may
  #   contain a single entry) of the comments to be submitted for retraining.
  #   Note that a signature for each comment was originally provided by the
  #   {#audit_comment} method.
  # @raise [StandardError] If the call fails, a StandardError is raised with
  #   the error message given from Defensio.
  # @return [Boolean] Returns true if the comments were successfully marked,
  #   raises StandardError otherwise.
  def report_false_positives(signatures)
    response = call_action("report-false-positives",
                           "signatures" => signatures.map(&:to_s).join(","))
    true
  end
  
  ##
  # This action returns basic statistics regarding the performance of Defensio
  # since activation.
  #
  # @return [Defender::Statistics]
  def statistics
    response = call_action("get-stats")
    return Statistics.new(response)
  end
  
  private
    ##
    # Returns the url for the given action.
    #
    # @param [#to_s] action The action to generate the URL for.
    # @return [String] The URL for the action.
    # @raise [APIKeyError] Raises this if no API key is given.
    def url(action)
      raise APIKeyError unless @api_key.length > 0
      "http://api.defensio.com/" \
      "#{@service_type}/" \
      "#{Defender::API_VERSION}/" \
      "#{action}/" \
      "#{@api_key}.yaml"
    end
    
    ##
    # Backend function for calling an action.
    #
    # @param [#to_s] action The action to call.
    # @param [Hash] params The parameters for the action.
    # @return [Hash] The raw response, only parsed from YAML.
    # @raise [APIKeyError] If an invalid (or no) API key is given, this is
    #   raised
    def call_action(action, params={})
      params = {"owner-url" => @owner_url}.merge(params)
      response = Net::HTTP.post_form(URI.parse(url(action)), params)
      if response.code == 401
        raise APIKeyError
      else
        Defender.raise_if_error(YAML.load(response.body)["defensio-result"])
      end
    end
end
