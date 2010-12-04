require 'active_model'

##
# A fake Comment class to use. No need to require ActiveRecord and set up an
# actual database. We will use ActiveModel for callbacks though.
class Comment
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  define_model_callbacks :save
  
  # We now have a "valid" model, let's bring in Defender.
  include Defender::Spammable
  
  attr_accessor :body, :author, :author_ip, :created_at, :spam, :defensio_sig
  
  def new_record?
    !@saved ||= false
  end
  
  def save
    _run_save_callbacks do
      # We're not actually saving anything, just letting Defender know we
      # would be.
      @saved = true
    end
  end
end