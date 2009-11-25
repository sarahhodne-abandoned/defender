##
# The response from the {Defender#audit_comment} method. Should only be
# initialized by the library.
class Defender::CommentResponse
  ##
  # A message signature that uniquely identifies the comment in the Defensio
  # system. This signature should be stored by the client for retraining
  # purposes.
  attr_reader :signature

  ##
  # A vaule indicating the relative likelihood of the comment being spam.
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
  def spam?; @spam; end

  def to_s; @signature; end
end
