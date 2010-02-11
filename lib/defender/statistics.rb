module Defender
  class Statistics
    class Extended
      ##
      # The starting date.
      #
      # @return [String] Is in the format YYYY-MM-DD.
      attr_reader :from

      ##
      # The ending date.
      #
      # @return [String] Is in the form YYYY-MM-DD.
      attr_reader :to

      ##
      # Provides a set of URLs that chart the data provided in the data array.
      #
      # The Hash returned will have the keys `:accuracy`, `:unwanted` and
      # `:legitimate`, which all refer to the same fields in the {#data} hash.
      #
      # @return [Hash{Symbol => String}]
      attr_reader :chart_urls

      ##
      # The set of dates within the retrieved period.
      #
      # The keys are Date objects.
      #
      # Each date has the following keys:
      #
      # * `:false_negatives` - The number of false negatives for the specified
      #   date.
      # * `:false_positives` - The number of false positives for the specified
      #   date.
      # * `:legitimate` - The number of legitimate documents processed on the
      #   specified date.
      # * `:accuracy` - How accurate Defensio has recently been for the current
      #   user on the specified date. This is returned as a Float between 0
      #   and 1. For example, 0.9525 means 95.25% accurate.
      # * `:unwanted` - The number of unwanted documents processed on the
      #   specified date.
      #
      # @return [Hash{Date => Hash{Symbol => Object}}]
      attr_reader :data

      ##
      # Retrieves extended statistics from a given date to another one.
      #
      # @param [#strftime, #to_s] from The starting date.
      # @param [#strftime, #to_s] to The ending date.
      def initialize(from, to)
        @from = from.respond_to?(:strftime) ? from.strftime('%Y-%m-%d') : from.to_s
        @to = to.respond_to?(:strftime) ? to.strftime('%Y-%m-%d') : to.to_s

        code, response = Defender.defensio.get_extended_stats(:from => @from, :to => @to)
        if response['status'] == 'success'
          @chart_urls = {
            :accuracy => response['chart-urls']['recent-accuracy'],
            :unwanted => response['chart-urls']['total-unwanted'],
            :legitimate => response['chart-urls']['total-legitimate']
          }

          @data = {}
          response['data'].each do |data|
            @data[data['date']] = {
              :false_negatives => data['false-negatives'],
              :false_positives => data['false-positives'],
              :legitimate => data['legitimate'],
              :accuracy => data['recent-accuracy'],
              :unwanted => data['unwanted']
            }
          end
        else
          raise StandardError, response['message']
        end
      end
    end

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
    # Initialize the object and retrieve basic statistics.
    #
    # @raise StandardError if any of the calls to the server during retrieving
    #   of statistics fail.
    def initialize
      retrieve_basic_stats
    end

    private

    def retrieve_basic_stats
      code, response = Defender.defensio.get_basic_stats

      if code == 200 && response['status'] == 'success'
        @api_version = response['api-version']
        @false_negatives = response['false-negatives']
        @false_positives = response['false-positives']
        @learning = response['learning']
        @learning_status = response['learning-status']
        @legitimate_total = response['legitimate']['total']
        @recent_accuracy = response['recent-accuracy']
        @unwanted_malicious = response['unwanted']['malicious']
        @unwanted_spam = response['unwanted']['spam']
        @unwanted_total = response['unwanted']['total']
      else
        raise StandardError, response['message']
      end
    end
  end
end
