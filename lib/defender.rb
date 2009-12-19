require 'httparty'

require 'defender/document'
require 'defender/statistics'

module Defender
  VERSION = "0.2.0"

  include HTTParty

  # The Defensio API version currently supported by Defender
  API_VERSION = "2.0"

  # HTTParty config
  format :json
  base_uri "api.defensio.com/#{API_VERSION}/users"

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
  # @return [Boolean] Whether the API key was valid or not.
  def self.check_api_key
    key = Defender.api_key
    return false unless key
    resp = get("/#{key}.json")['defensio-result']
    if resp['status'] == 'success'
      return true
    else
      return false
    end
  end
end
