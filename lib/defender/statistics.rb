module Defender
  class Statistics
    ##
    # The version of the Defensio API being used. Should be the same as
    # {Defender::API_VERSION}.
    #
    # @return [String]
    attr_reader :api_version

    ##
    # The number of documents that have been allowed but that should have been
    # blocked.
    #
    # @return [Fixnum]
    attr_reader :false_negatives

    ##
    # The number of documents that have been blocked but that should have been
    # allowed.
    #
    # @return [Fixnum]
    attr_reader :false_positives

    ##
    # Whether Defensio is learning from the documents you post.
    #
    # @return [Boolean]
    attr_reader :learning

    ##
    # A message explaining why Defensio is in learning mode.
    #
    # @return [String]
    attr_reader :learning_status

    ##
    # The total number of legitimate documents analyzed.
    #
    # @return [Fixnum]
    attr_reader :legitimate_total

    ##
    # How accurate Defensio has recently been for this user.
    #
    # This returns a floating point value between 0 and 1. For example, 0.9525
    # means 95.25% accurate.
    #
    # @return [Float<0..1>]
    attr_reader :recent_accuracy

    ##
    # The number of documents containing malicious content.
    #
    # @return [Fixnum]
    attr_reader :unwanted_malicious

    ##
    # The number of spam documents analyzed.
    #
    # @return [Fixnum]
    attr_reader :unwanted_spam

    ##
    # The total number of unwanted documents.
    #
    # @return [Fixnum]
    attr_reader :unwanted_total

    ##
    # Initialize the object and retrieve statistics. If no parameters are given,
    # basic statistics are given. If two Date objects are passed, extended
    # satistics will be retrieved for this timespan.
    #
    # @param [Date] from The starting date.
    # @param [Date] to The ending date.
    #
    # @raise StandardError if any of the calls to the server during retrieving
    #   of statistics fail.
    def initialize(from=nil, to=nil)
      if from && to
        retrieve_extended_statistics
      else
        retrieve_basic_statistics
      end
    end

    private

    def retrieve_basic_stats
      code, response = Defender.get(Defender.uri("/basic-stats"))

      if code != 200
        raise StandardError, response["message"]
      else
        @false_negatives = response["false-negatives"]
        @false_positives = response["false-positives"]
        @learning = response["learning"]
        @learning_status = response["learning-status"]
        @legitimate_total = response["legitimate"]["total"]
        @recent_accuracy = response["recent-accuracy"]
        @unwanted_malicious = response["unwanted"]["malicious"]
        @unwanted_spam = response["unwanted"]["spam"]
        @unwanted_total = response["unwanted"]["total"]
      end
    end
  end
end
