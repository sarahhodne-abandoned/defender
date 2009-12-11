require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender::Document do
  context "creating documents" do
    it "should allow an innocent document to be posted when given only required options" do
      Defender.expects(:request).with(:post, "/2.0/users/foobar/documents.yaml", {
        "client" => "Defender | #{Defender::VERSION} | Henrik Hodne | henrik.hodne@binaryhex.com",
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
      Defender.expects(:request).with(:post, "/2.0/users/foobar/documents.yaml", {
        "client" => "Defender | #{Defender::VERSION} | Henrik Hodne | henrik.hodne@binaryhex.com",
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

    it "raises a StandardError on server error" do
      Defender.expects(:request).with(:post, "/2.0/users/foobar/documents.yaml", {
        "client" => "Defender | #{Defender::VERSION} | Henrik Hodne | henrik.hodne@binaryhex.com",
        "content" => "[spam,0.89]",
        "platform" => "ruby",
        "type" => "test"
      }).returns([500,
        {
          "api-version" => "2.0",
          "status" => "failed",
          "message" => "Oopsies"
        }
      ])

      Defender.api_key = "foobar"
      document = Defender::Document.new
      document.content = "[spam,0.89]"
      document.type = :test
      lambda { document.save }.should raise_error(StandardError, "Oopsies")
    end
  end

  context "finding documents" do
    it "sets the attributes for a found object" do
      Defender.expects(:request).with(:get, "/2.0/users/foobar/documents/baz.yaml", nil).
        returns([200,
          {
            "api-version" => "2.0",
            "status" => "success",
            "message" => "",
            "signature" => "baz",
            "allow" => false,
            "classification" => "spam",
            "spaminess" => 0.89,
            "profanity-match" => false
          }
        ])

      Defender.api_key = "foobar"
      document = Defender::Document.find("baz")
      document.allow?.should be_false
      document.classification.should == "spam"
      document.spaminess.should == 0.89
      document.profane?.should be_false
      document.signature.should == "baz"
    end

    it "raises a StandardError on server error" do
      Defender.expects(:request).with(:get, "/2.0/users/foobar/documents/baz.yaml", nil).
        returns([500,
          {
            "api-version" => "2.0",
            "status" => "failed",
            "message" => "oops",
          }
        ])

      Defender.api_key = "foobar"
      lambda { Defender::Document.find("baz") }.should raise_error(StandardError, "oops")
    end
  end

  context "updating documents" do
    it "only sets the allow attribute" do
      Defender.expects(:request).with(:get, "/2.0/users/foobar/documents/baz.yaml", nil).
        returns([200,
          {
            "api-version" => "2.0",
            "status" => "success",
            "message" => "",
            "signature" => "baz",
            "allow" => false,
            "classification" => "spam",
            "spaminess" => 0.89,
            "profanity-match" => false
          }
        ])
      Defender.expects(:request).with(:put, "/2.0/users/foobar/documents/baz.yaml", {'allow' => true}).
        returns([200,
          {
            "api-version" => "2.0",
            "status" => "success",
            "message" => "",
            "signature" => "baz",
            "allow" => false,
            "classification" => "spam",
            "spaminess" => 0.89,
            "profanity-match" => false
          }
        ])

      Defender.api_key = "foobar"
      document = Defender::Document.find("baz")
      document.allow = true
      oldcontent = document.content
      lambda { document.content = "foobar!" }.should raise_error(NameError)
      document.save.should be_true
      document.content.should == oldcontent
      document.content.should_not == "foobar!"
    end

    it "raises a StandardError when the server encounts an error" do
      Defender.expects(:request).with(:get, "/2.0/users/foobar/documents/baz.yaml", nil).
        returns([200,
          {
            "api-version" => "2.0",
            "status" => "success",
            "message" => "",
            "signature" => "baz",
            "allow" => false,
            "classification" => "spam",
            "spaminess" => 0.89,
            "profanity-match" => false
          }
        ])
      Defender.expects(:request).with(:put, "/2.0/users/foobar/documents/baz.yaml", {'allow' => true}).
        returns([500,
          {
            "api-version" => "2.0",
            "status" => "failed",
            "message" => "UTTER FAIL!",
          }
        ])

      Defender.api_key = "foobar"
      document = Defender::Document.find("baz")
      document.allow = true
      lambda { document.save }.should raise_error(StandardError, "UTTER FAIL!")
    end
  end
end
