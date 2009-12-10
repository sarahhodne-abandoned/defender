require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender::Document do
  context "creating documents" do
    it "should allow an innocent document to be posted when given only required options" do
      Defender.stubs(:request).with(:post, "/2.0/users/foobar/documents.yaml", {
        "client" => "Defender | 0.2 | Henrik Hodne | henrik.hodne@binaryhex.com",
        "content" => "[innocent,0.1]",
        "platform" => "ruby",
        "type" => "test"
      }).returns([200,
        {
          "api-version" => "2.0",
          "status" => "success",
          "message" => "",
          "signature" => "baz",
          "allow" => true,
          "classification" => "innocent",
          "spaminess" => 0.1,
          "profanity-match" => false
        }])

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

    it "should not allow a spammy document to be posted when given only required options" do
      Defender.stubs(:request).with(:post, "/2.0/users/foobar/documents.yaml", {
        "client" => "Defender | 0.2 | Henrik Hodne | henrik.hodne@binaryhex.com",
        "content" => "[spam,0.89]",
        "platform" => "ruby",
        "type" => "test"
      }).returns([200,
        {
          "api-version" => "2.0",
          "status" => "success",
          "message" => "",
          "signature" => "bar",
          "allow" => false,
          "classification" => "spam",
          "spaminess" => 0.89,
          "profanity-match" => false
        }
      ])

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
  end
end
