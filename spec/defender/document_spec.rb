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
      let(:defensio) { double('defensio') }
      before(:each) { Defender.defensio = defensio }

      it 'rewrites the data hash keys' do
        @document.data[:content] = '[innocent,0.1]'

        data = @document.data
        data['content'] = data[:content]
        data.delete(:content)

        defensio.should_receive(:post_document).with(data).and_return([200, {'allow' => true, 'status' => 'success'}])

        @document.save
      end

      it 'queries defensio for the data' do
        @document.data['content'] = '[innocent,0.1]'

        defensio.should_receive(:post_document).with(@document.data).and_return([200, {'allow' => true}])

        @document.save
      end

      it 'saves the signature' do
        @document.data['content'] = '[innocent,0.1]'

        defensio.should_receive(:post_document).with(@document.data).and_return([200, {'status' => 'success', 'allow' => true, 'signature' => 'foobar'}])

        @document.save

        @document.signature.should == 'foobar'
      end

      it 'saves the spaminess' do
        @document.data['content'] = '[innocent,0.1]'

        defensio.should_receive(:post_document).with(@document.data).and_return([200, {'status' => 'success', 'allow' => true, 'signature' => 'foobar', 'spaminess' => 0.1}])

        @document.save

        @document.spaminess.should == 0.1
      end

      it 'sends a PUT and not a POST if the document has been sent before' do
        defensio.should_receive(:get_document).with('foo').and_return([200, {'allow' => true, 'status' => 'success'}])

        @document = Defender::Document.find('foo')

        @document.allow = false

        defensio.should_receive(:put_document).with('foo', {:allow => false}).and_return([200, {'allow' => false}])

        @document.save
      end

      it 'returns true if the operation succeeds' do
        @document.data[:content] = '[innocent,0.1]'
        defensio.should_receive(:post_document).and_return([200, {'status' => 'success', 'allow' => true, 'signature' => 'foobar'}])

        @document.save.should be_true
      end

      it 'returns false if the operation fails' do
        @document.data[:content] = '[innocent,0.1]'
        defensio.should_receive(:post_document).and_return([500, {'status' => 'failed'}])

        @document.save.should be_false
      end
    end

    describe '#saved?' do
      it 'returns false for new objects' do
        @document.saved?.should be_false
      end

      it 'returns true for objects that have been saved' do
        defensio = double('defensio')
        Defender.defensio = defensio
        defensio.should_receive(:post_document).with(@document.data).and_return([200, {'status' => 'success', 'allow' => true}])

        @document.save
        @document.saved?.should be_true
      end
    end

    describe '.normalize_data' do
      it 'stringifies keys' do
        original = {:foo => 'bar', :baz => 'foobar'}
        normalized = {'foo' => 'bar', 'baz' => 'foobar'}
        Defender::Document.normalize_data(original).should == normalized
      end

      it 'stringifies values' do
        original = {'foo' => :bar, 'baz' => :foobar}
        normalized = {'foo' => 'bar', 'baz' => 'foobar'}
        Defender::Document.normalize_data(original).should == normalized
      end

      it 'formats date objects in the YYYY-MM-DD format' do
        original = {'date' => Time.at(0)}
        normalized = {'date' => '1970-01-01'}
        Defender::Document.normalize_data(original).should == normalized
      end
    end
  end
end
