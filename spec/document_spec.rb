require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender::Document do
  before(:each) do
    Defender.api_key = "foobar"
    @defensio = Defender.defensio
  end

  context "creating documents" do
    it "should allow an innocent document to be posted when given only required options" do
      document = Defender::Document.new
      document.content = '[innocent,0.1]'
      document.type = :test
      
      @defensio.expects(:post_document).with(document.attributes_hash).returns(
        [200, {
          'api-version' => '2.0',
          'status' => 'success',
          'message' => '',
          'signature' => 'baz',
          'allow' => true,
          'classification' => 'innocent',
          'spaminess' => 0.1,
          'profanity-match' => false
        }]
      )
      
      document.save

      document.allow?.should be_true
      document.classification.should == "innocent"
      document.spaminess.should == 0.1
      document.profane?.should be_false
      document.signature.should == "baz"
    end

    it "marks an asynchronously requested document as pending" do
      Defender.api_key = "foobar"
      document = Defender::Document.new
      document.content = "[innocent,0.1]"
      document.type = :test

      @defensio.expects(:post_document).with(document.attributes_hash.merge({'async' => 'true'})).returns(
        [200, {
          'api-version' => '2.0',
          'status' => 'pending',
          'message' => '',
          'signature' => 'baz',
          'allow' => nil,
          'classification' => nil,
          'spaminess' => nil,
          'profanity-match' => nil
        }]
      )

      document.save(true)

      document.pending?.should be_true
    end

    it "should not allow a spammy document to be posted when given only required options" do
      document = Defender::Document.new
      document.content = "[spam,0.89]"
      document.type = :test

      @defensio.expects(:post_document).with(document.attributes_hash).returns(
        [200, {
          'api-version' => '2.0',
          'status' => 'success',
          'message' => '',
          'signature' => 'bar',
          'allow' => false,
          'classification' => 'spam',
          'spaminess' => 0.89,
          'profanity-match' => false
        }]
      )

      document.save

      document.allow?.should be_false
      document.classification.should == "spam"
      document.spaminess.should == 0.89
      document.profane?.should be_false
      document.signature.should == "bar"
    end

    it "accepts a string to parent-document-date" do
      document = Defender::Document.new
      document.parent_document_date = '1970-01-01'
      document.attributes_hash['parent-document-date'].should == '1970-01-01'
    end

    it "accepts a Time to parent-document-date" do
      time = Time.now
      document = Defender::Document.new
      document.parent_document_date = time
      document.attributes_hash['parent-document-date'].should == time.strftime('%Y-%m-%d')
    end

    it "accepts a hash as headers" do
      document = Defender::Document.new
      document.http_headers = {"Foo" => "Bar", "Bar" => "Baz"}
      document.attributes_hash['http-headers'].should == "Foo: Bar\nBar: Baz"
    end

    it "accepts an array as headers" do
      document = Defender::Document.new
      document.http_headers = ["Foo: Bar", "Bar: Baz"]
      document.attributes_hash['http-headers'].should == "Foo: Bar\nBar: Baz"
    end

    it "returns false on server error" do
      document = Defender::Document.new
      document.content = "[spam,0.89]"
      document.type = :test
      
      @defensio.expects(:post_document).with(document.attributes_hash).returns(
        [500, {
          'api-version' => '2.0',
          'status' => 'failed',
          'message' => 'Oopsies'
        }]
      )

      document.save.should be_false
    end
  end

  context "finding documents" do
    it "sets the attributes for a found object" do
      @defensio.expects(:get_document).with('baz').returns(
        [200, {
          'api-version' => '2.0',
          'status' => 'success',
          'message' => '',
          'signature' => 'baz',
          'allow' => false,
          'classification' => 'spam',
          'spaminess' => 0.89,
          'profanity-match' => false
        }]
      )

      document = Defender::Document.find('baz')
      document.allow?.should be_false
      document.classification.should == "spam"
      document.spaminess.should == 0.89
      document.profane?.should be_false
      document.signature.should == "baz"
    end

    it "raises a StandardError on server error" do
      @defensio.expects(:get_document).with('baz').returns(
        [500, {
          'api-version' => '2.0',
          'status' => 'failed',
          'message' => 'oops'
        }]
      )

      lambda { Defender::Document.find('baz') }.should raise_error(StandardError, 'oops')
    end
  end

  context "updating documents" do
    it "only sets the allow attribute" do
      @defensio.expects(:get_document).with('baz').returns(
        [200, {
          'api-version' => '2.0',
          'status' => 'success',
          'message' => '',
          'signature' => 'baz',
          'allow' => false,
          'classification' => 'spam',
          'spaminess' => 0.89,
          'profanity-match' => false
        }]
      )

      document = Defender::Document.find('baz')
      document.allow = true
      oldcontent = document.content
      lambda { document.content = 'foobar!' }.should raise_error(NameError)
      
      @defensio.expects(:put_document).with('baz', {'allow' => true}).returns(
        [200, {
          'api-version' => '2.0',
          'status' => 'success',
          'message' => '',
          'signature' => 'baz',
          'allow' => true,
          'classification' => 'spam',
          'spaminess' => 0.89,
          'profanity-match' => false
        }]
      )
      
      document.save.should be_true
      document.content.should == oldcontent
      document.content.should_not == 'foobar!'
      document.allow.should be_true
    end

    it 'returns false when the server encounts an error' do
      @defensio.expects(:get_document).with('baz').returns(
        [200, {
          'api-version' => '2.0',
          'status' => 'success',
          'message' => '',
          'signature' => 'baz',
          'allow' => false,
          'classification' => 'spam',
          'spaminess' => 0.89,
          'profanity-match' => false
        }]
      )

      document = Defender::Document.find('baz')
      document.allow = true
      
      @defensio.expects(:put_document).with('baz', {'allow' => true}).returns(
        [500, {
          'api-version' => '2.0',
          'status' => 'failed',
          'message' => 'UTTER FAIL!'
        }]
      )
      
      document.save.should be_false
    end
  end
end
