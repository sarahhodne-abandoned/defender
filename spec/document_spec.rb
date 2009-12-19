require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender::Document do
  before(:each) do
    FakeWeb.clean_registry
  end

  context "creating documents" do
    it "should allow an innocent document to be posted when given only required options" do
      FakeWeb.register_uri(:post, "http://api.defensio.com/2.0/users/foobar/documents.json",
                           :body => '{"defensio-result":{"api-version":"2.0","status":"success","message":"","signature":"baz",
                                      "allow":true,"classification":"innocent","spaminess":0.1,
                                      "profanity-match":false}}')
      Defender.api_key = "foobar"
      document = Defender::Document.new
      document.content = "[innocent,0.1]"
      document.type = :test
      document.save

      document.allow?.should be_true
      document.classification.should == "innocent"
      document.spaminess.should == 0.1
      document.profane?.should be_false
      document.signature.should == "baz"
    end

    it "marks an asynchronously requested document as pending" do
      FakeWeb.register_uri(:post, "http://api.defensio.com/2.0/users/foobar/documents.json",
                           :body => '{"defensio-result":{"api-version":"2.0","status":"pending","message":"","signature":"baz",
                           "allow":null,"classification":null,"spaminess":null,"profanity-match":null}}')

      Defender.api_key = "foobar"
      document = Defender::Document.new
      document.content = "[innocent,0.1]"
      document.type = :test
      document.save(true)

      document.pending?.should be_true
    end

    it "should not allow a spammy document to be posted when given only required options" do
      FakeWeb.register_uri(:post, "http://api.defensio.com/2.0/users/foobar/documents.json",
                           :body => '{"defensio-result":{"api-version":"2.0","status":"success","message":"","signature":"bar",
                           "allow":false,"classification":"spam","spaminess":0.89,"profanity-match":false}}')

      Defender.api_key = "foobar"
      document = Defender::Document.new
      document.content = "[spam,0.89]"
      document.type = :test
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
      FakeWeb.register_uri(:post, "http://api.defensio.com/2.0/users/foobar/documents.json",
                           :body => '{"defensio-result":{"api-version":"2.0","status":"failed","message":"Oopsies"}}',
                           :status => ["500", "Server Error"])
      Defender.api_key = "foobar"
      document = Defender::Document.new
      document.content = "[spam,0.89]"
      document.type = :test
      document.save.should be_false
    end
  end

  context "finding documents" do
    it "sets the attributes for a found object" do
      FakeWeb.register_uri(:get, "http://api.defensio.com/2.0/users/foobar/documents/baz.json",
                           :body => '{"defensio-result":{"api-version":"2.0","status":"success","message":"",
                           "signature":"baz","allow":false,"classification":"spam","spaminess":0.89,"profanity-match":false}}')

      Defender.api_key = "foobar"
      document = Defender::Document.find("baz")
      document.allow?.should be_false
      document.classification.should == "spam"
      document.spaminess.should == 0.89
      document.profane?.should be_false
      document.signature.should == "baz"
    end

    it "raises a StandardError on server error" do
      FakeWeb.register_uri(:get, "http://api.defensio.com/2.0/users/foobar/documents/baz.json",
                           :body => '{"defensio-result":{"api-version":"2.0","status":"failed","message":"oops"}}',
                           :status => ["500", "Server Error"])

      Defender.api_key = "foobar"
      lambda { Defender::Document.find("baz") }.should raise_error(StandardError, "oops")
    end
  end

  context "updating documents" do
    it "only sets the allow attribute" do
      FakeWeb.register_uri(:get, 'http://api.defensio.com/2.0/users/foobar/documents/baz.json',
                           :body => '{"defensio-result":{"api-version":"2.0","status":"success","message":"",
                           "signature":"baz","allow":false,"classification":"spam","spaminess":0.89,"profanity-match":false}}')
      FakeWeb.register_uri(:put, 'http://api.defensio.com/2.0/users/foobar/documents/baz.json',
                           :body => '{"defensio-result":{"api-version":"2.0","status":"success","message":"",
                           "signature":"","allow":true,"classification":"spam","spaminess":0.89,"profanity-match":false"}}')

      Defender.api_key = 'foobar'
      document = Defender::Document.find('baz')
      document.allow = true
      oldcontent = document.content
      lambda { document.content = 'foobar!' }.should raise_error(NameError)
      document.save.should be_true
      document.content.should == oldcontent
      document.content.should_not == 'foobar!'
      document.allow.should be_true
    end

    it 'returns false when the server encounts an error' do
      FakeWeb.register_uri(:get, 'http://api.defensio.com/2.0/users/foobar/documents/baz.json',
                           :body => '{"defensio-result":{"api-version":"2.0","status":"success","message":"",
                           "signature":"baz","allow":false,"classification":"spam","spaminess":0.89,"profanity-match":false}}')
      FakeWeb.register_uri(:put, 'http://api.defensio.com/2.0/users/foobar/documents/baz.json',
                           :body => '{"defensio-result":{"api-version":"2.0","status":"failed","message":"UTTER FAIL!"}}',
                           :status => ['500', 'Server Error'])

      Defender.api_key = 'foobar'
      document = Defender::Document.find('baz')
      document.allow = true
      document.save.should be_false
    end
  end
end
