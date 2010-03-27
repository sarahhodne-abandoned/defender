require 'spec_helper'
require 'fake_defensio'

module Defender
  describe Document do
    before(:each) { @document = Defender::Document.new }

    describe '#allow?' do
      before(:all) do
        Defender.defensio = FakeDefensio.new
      end

      it 'returns true for a hammy document' do
        @document.data[:content] = '[innocent,0.1]'
        @document.save
        @document.allow?.should be_true
      end

      it 'returns false for a spammy document' do
        @document.data[:content] = '[spam,0.9]'
        @document.save
        @document.allow?.should be_false
      end
    end

    describe '#save' do
      it 'queries defensio for the data' do
        defensio = double('defensio')
        Defender.defensio = defensio
        @document.data[:content] = '[innocent,0.1]'

        defensio.should_receive(:post_document).with(@document.data).and_return([200, {'allow' => true}])

        @document.save
      end

      it 'saves the signature' do
        defensio = double('defensio')
        Defender.defensio = defensio
        @document.data[:content] = '[innocent,0.1]'

        defensio.should_receive(:post_document).with(@document.data).and_return([200, {'allow' => true, 'signature' => 'foobar'}])

        defensio.save

        @document.signature.should == 'foobar'
      end

      it 'sends a PUT and not a POST if the document has been sent before' do
        defensio = double('defensio')
        Defender.defensio = defensio
        @document.data[:content] = '[innocent,0.1]'

        defensio.should_receive(:post_document).with(@document.data).and_return([200, {'allow' => true}])

        @document.save
        @document.allow = false

        defensio.should_receive(:put_document).with({:allow => false}).and_return([200, {'allow' => false}])

        @document.save
      end
    end
  end
end
