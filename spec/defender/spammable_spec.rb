require 'spec_helper'

module Defender
  describe Spammable do
    describe '#spam?' do
      it 'returns the "spam" attribute unless it is nil' do
        comment_class = Class.new
        comment_class.instance_eval { attr_accessor :spam }
        def comment_class.before_save(*args, &block); end
        comment_class.send(:define_method, :new_record?) { false }
        comment_class.send(:include, Defender::Spammable)
        comment = comment_class.new
        comment.spam = true
        comment.spam?.should be_true
      end
      
      it 'returns nil for a new record' do
        comment_class = Class.new
        comment_class.instance_eval { attr_accessor :spam }
        def comment_class.before_save(*args, &block); end
        comment_class.send(:define_method, :new_record?) { true }
        comment_class.send(:include, Defender::Spammable)
        comment = comment_class.new
        comment.spam?.should be_nil
      end
      
      it 'raises a DefenderError if no spam attribute exists' do
        comment_class = Class.new
        def comment_class.before_save(*args, &block); end
        comment_class.send(:define_method, :new_record?) { false }
        comment_class.send(:include, Defender::Spammable)
        comment = comment_class.new
        expect { comment.spam? }.to raise_error(Defender::DefenderError)
      end
    end
    
    describe '#_defender_before_save' do
      it 'sets the attributes returned from defensio' do
        comment = Comment.new
        comment.body = '[innocent,0.9]'
        comment.save
        comment.spam.should be_false
        comment.defensio_sig.should_not be_nil
      end
      
      it 'sends the information off to Defensio' do
        old_defensio = Defender.defensio
        defensio = double('defensio')
        defensio.should_receive(:post_document) { [200, {'signature' => 1234567890, 'spaminess' => 0.9, 'allow' => true}] }
        Defender.defensio = defensio
        comment = Comment.new
        comment.body = 'Hello, world!'
        comment.save
      end
    end
  end
end