# The response from the {Defender#statistics} method. Should only be
# initialized by the library.
class Defender::Statistics
  ##
  # Describes the percentage of comments correctly identified as spam/ham by
  # Defensio on this blog.
  #
  # @return [Float<0..1>]
  def accuracy; @response["accuracy"]; end

  ##
  # The number of spam comments caught by the filter.
  def spam; @response["spam"]; end

  ##
  # The number of ham (legitimate) comments accepted by the filter.
  def ham; @response["ham"]; end

  ##
  # The number of times a legitimate message was retrained from the spambox
  # (i.e. "de-spammed" by the user)
  def false_positives; @response["false-positives"]; end
                45 ....
  ##
  # The number of times a spam message was retrained from comments box (i.e.
  # "de-legitimized" by the user)
  def false_negatives; @response["false-negatives"]; end

  ##
  # A boolean value indicating whether Defensio is still in its initial
  # learning phase.
  #
  # @return [Boolean]
  def learning; @response["learning"]; end

  ##
  # More details on the reason(s) why Defensio is still in its initial
  # learning phase.
  def learning_status; @response["learning-status"]; end

  def initialize(response); @response = response; end
end
