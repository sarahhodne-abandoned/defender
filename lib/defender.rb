require 'yaml'
require 'net/http'
require 'cgi'

require 'defender/document'
require 'defender/statistics'

module Defender
  VERSION = "0.2.0"

  # The Defensio API version currently supported by Defender
  API_VERSION = "2.0"

  SERVER_HOSTNAME = "api.defensio.com"

  HTTP_METHODS =  {:get => Net::HTTP::Get, :post => Net::HTTP::Post,
                   :put => Net::HTTP::Put, :delete => Net::HTTP::Delete}

  class << self
    ##
    # Your Defensio API key. You need to register at defensio.com to get a key.
    attr_accessor :api_key

    ##
    # The URL that will be called when Defensio is done analyzing a comment with
    # asynchronous callbacks. You should be able to pass the request parameters
    # straight into {Document#set_attributes}. The signature will be in the
    # `signature` parameter.
    #
    # *IMPORTANT*: Defensio will NOT retry unsuccessful callbacks to your
    # server. If you do not see a POST originating from Defensio after 5
    # minutes, call {Document#refresh!} on the document to obtain the analysis
    # result.
    #
    # Occasionally, Defensio may perform more than one POST request to your
    # server for the same document. For example, if new evidence indicates that
    # a document is unwanted, even though it was originally identified as
    # legitimate, Defensio might notify you that the classification has changed.
    #
    # If you do not provide this and use asynchronous calling, you need to call
    # {Document#refresh!} to get the analysis result.
    #
    # You can debug callbacks using http://postbin.org. See the Defensio API
    # documents for the format of the requests.
    #
    # @return [String]
    attr_accessor :async_callback
  end

  ##
  # Determines if the given API key is valid or not. This should only be used
  # when configuring the client and prior to every content analysis (Document
  # POST).
  #
  # Set the API key using {Defender.api_key}.
  #
  # @raise [StandardError] If an unexpected result was hit (not valid, nor
  #   invalid), then a StandardError will be raised.
  # @return [Boolean] Whether the API key was valid or not.
  def self.check_api_key
    key = Defender.api_key
    return false unless key
    code, resp = get(uri())
    case code
    when 200
      return true
    when 401, 404
      return false
    else
      raise StandardError, resp['message']
    end
  end

  ##
  # Sends a GET request and parses the YAML response to a hash.
  #
  # @param [String] uri The URI to GET.
  # @param [Hash{#to_s => #to_s}] attributes The attributes to pass. Will be
  #   URL encoded automatically.
  def self.get(uri, attributes=nil)
    if attributes && attributes.length > 0
      uri = uri + "?" + hash_to_http(attributes)
    end
    request(:get, uri)
  end

  ##
  # Sends a POST request and parses the YAML response to a hash.
  #
  # @param [String] uri The URI to POST.
  # @param [Hash{#to_s => #to_s}] attributes The attributes to pass. Will be
  #   URL encoded automatically.
  def self.post(*args)
    request(:post, *args)
  end

  ##
  # Sends a PUT request and parses the YAML response to a hash.
  #
  # @param [String] uri The URI to PUT.
  # @param [Hash{#to_s => #to_s}] attributes The attributes to pass. Will be
  #   URL encoded automatically.
  def self.put(*args)
    request(:put, *args)
  end

  ##
  # Sends a DELETE request and parses the YAML response to a hash.
  #
  # @param [String] uri The URI to DELETE.
  # @param [Hash{#to_s => #to_s}] attributes The attributes to pass. Will be
  #   URL encoded automatically.
  def self.delete(*args)
    request(:delete, *args)
  end

  private

  ##
  # Returns a URI mixing in the API version and the API key.
  #
  # @param [String] uri The portion of the URI after the API key and before the
  # format of the response (if any).
  def self.uri(uri="")
    "/#{API_VERSION}/users/#{api_key}" + uri + ".yaml"
  end

  ##
  # The method that does the HTTP requests and URL encodes the attributes.
  # It will also parse the response from YAML and return the defensio-result
  # field.
  #
  # @param [:get, :post, :put, :delete] method The HTTP method to use.
  # @param [String] uri The URI to request.
  # @param [Hash{#to_s => #to_s}] attributes The attributes to pass in the
  #    body. Will be automatically URL-encoded. Do not pass this (or pass nil)
  #    if a GET request is made, or it will raise an {ArgumentError}.
  def self.request(method, uri, attributes=nil)
    body = nil
    if method != :get && attributes && attributes.length > 0
      body = hash_to_http(attributes)
    end
    Net::HTTP.start(SERVER_HOSTNAME) do |http|
      response = http.request(HTTP_METHODS[method].new(uri), body)
      return [response.code.to_i, YAML.load(response.body)['defensio-result']]
    end
  end

  ##
  # Converts a Hash to a HTTP options hash, like foo=bar&baz=foobar
  #
  # @param [Hash{#to_s => #to_s}] hsh
  # @return [String]
  def self.hash_to_http(hsh)
    http_a = ""
    hsh.each do |key,value|
      http_a << CGI.escape(key.to_s) << "=" <<
        CGI.escape(value.to_s) << "&"
    end
    http_a[0..-2]
  end
end
