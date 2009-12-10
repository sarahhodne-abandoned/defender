require 'yaml'
require 'net/http'
require 'cgi'

require 'defender/document'

module Defender
  # The Defensio API version currently supported by Defender
  API_VERSION = "2.0"

  SERVER_HOSTNAME = "api.defensio.com"

  class << self
    attr_accessor :api_key
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
      uri = uri + "?"
      attributes.each do |key, value|
        uri << CGI.escape(key.to_s)
        uri << "="
        uri << CGI.escape(value.to_s)
        uri << "&"
      end
      uri = uri[0..-2]
    end
    request(:get, uri)
  end

  ##
  # Sends a POST request and parses the YAML response to a hash.
  #
  # @param [String] uri The URI to POST.
  # @param [Hash{#to_s => #to_s}] attributes The attributes to pass. Will be
  #   URL encoded automatically.
  def self.post(uri, attributes=nil)
    request(:post, uri, attributes)
  end

  ##
  # Sends a PUT request and parses the YAML response to a hash.
  #
  # @param [String] uri The URI to PUT.
  # @param [Hash{#to_s => #to_s}] attributes The attributes to pass. Will be
  #   URL encoded automatically.
  def self.put(uri, attributes=nil)
    request(:put, uri, attributes)
  end

  ##
  # Sends a DELETE request and parses the YAML response to a hash.
  #
  # @param [String] uri The URI to DELETE.
  # @param [Hash{#to_s => #to_s}] attributes The attributes to pass. Will be
  #   URL encoded automatically.
  def self.delete(uri, attributes=nil)
    request(:delete, uri, attributes)
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
    method = {:get => Net::HTTP::Get, :post => Net::HTTP::Post,
      :put => Net::HTTP::Put, :delete => Net::HTTP::Delete}[method]
    body = nil
    if attributes && attributes.length > 1
      body = ""
      attributes.each do |key, value|
        body << CGI.escape(key.to_s)
        body << "="
        body << CGI.escape(value.to_s)
        body << "&"
      end
      body = body[0..-2]
    end
    Net::HTTP.start(SERVER_HOSTNAME) do |http|
      req = method.new(uri)
      response = http.request(req, body)
      return [response.code.to_i, YAML.load(response.body)['defensio-result']]
    end
  end
end
