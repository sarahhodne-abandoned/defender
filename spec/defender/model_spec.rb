require 'spec_helper'

module Defender
  describe Model do
    describe '#defender_data' do
      it 'returns an object that responds to []' do
        Comment.new.defender_data.should respond_to(:[])
      end

      it 'returns an object that responds to [], and takes symbols' do
        expect {
          Comment.new.defender_data[:content]
        }.to_not raise_error
      end

      it 'automatically finds values of attributes with common names' do
        comment = Comment.new
        comment.body = 'Hello, world!'
        comment.defender_data[:content].should == 'Hello, world!'
      end

      it 'automatically finds values of attributes in associations with common names' do
        author = double('Author')
        author.stub(:email) { 'me@example.com' }
        comment = Comment.new
        comment.stub(:author) { author }
        comment.defender_data[:author_email].should == 'me@example.com'
      end
    end
  end
end
