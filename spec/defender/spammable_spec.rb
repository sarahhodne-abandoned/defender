require 'spec_helper'

module Defender
  describe Spammable do
    describe '.configure_defender' do
      it 'sets the attribute-data key mappers' do
        Comment.configure_defender(:keys => {'foo' => :bar, 'foobar' => :baz})
        Comment._defensio_keys.should include({'foo' => :bar, 'foobar' => :baz})
      end
      
      it 'sets the API key' do
        Comment.configure_defender(:api_key => 'foobar')
        Defender.api_key.should == 'foobar'
      end
    end
    
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
    
    describe '#defensio_data' do
      it 'merges in more data to be sent to Defensio' do
        comment = Comment.new
        comment.defensio_data({'foo' => 'FOOBAR', 'foobar' => 'baz'})
        comment.defensio_data.should include({'foo' => 'FOOBAR', 'foobar' => 'baz'})
      end
      
      it 'overwrites values repassed' do
        comment = Comment.new
        comment.defensio_data({'foo' => 'FOOBAR'})
        comment.defensio_data({'foo' => 'baz'})
        comment.defensio_data['foo'].should == 'baz'
      end
      
      it 'leaves values that aren\'t modified' do
        comment = Comment.new
        comment.defensio_data({'foo' => 'baz'})
        comment.defensio_data({'bar' => 'foobar'})
        comment.defensio_data['foo'].should == 'baz'
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
        Defender.defensio = old_defensio
      end
    end
    
    describe '#_pick_attribute' do
      it 'returns the value of the attribute passed if it exists' do
        comment = Comment.new
        comment.body = 'Foobar!'
        comment.send(:_pick_attribute, :body).should == 'Foobar!'
      end
      
      it 'returns the value for the first attribute that exists in a list of attributes' do
        comment = Comment.new
        comment.body = 'Foobar!'
        comment.send(:_pick_attribute, [:content, :body]).should == 'Foobar!'
      end
      
      it 'returns nil if no attribute with the given names exists' do
        comment = Comment.new
        comment.send(:_pick_attribute, :bogus_attribute).should be_nil 
      end
    end
    
    describe '#_get_defensio_document' do
      it 'retrieves the document from Defensio' do
        old_defensio = Defender.defensio
        defensio = double('defensio')
        defensio.should_receive(:get_document) { [200, {'status' => 'succeed'}] }
        Defender.defensio = defensio
        comment = Comment.new
        comment.defensio_sig = '0123456789abcdef'
        comment.send(:_get_defensio_document)
        Defender.defensio = old_defensio
      end
    end
  end
end