require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender::Statistics do
  before(:each) do
    FakeWeb.clean_registry
  end

  it "retrieves basic statistics from the server" do
    FakeWeb.register_uri(:get, "http://api.defensio.com/2.0/users/foobar/basic-stats.json",
                         :body => '{"defensio-result":{"api-version":"2.0","status":"success","message":"",
                         "false-negatives":42,"false-positives":1,"learning":true,
                         "learning-status":"foo!","legitimate":{"total":15},
                         "recent-accuracy":0.9525,"unwanted":{"malicious":2,"spam":5,
                         "total":7}}}')

    Defender.api_key = "foobar"
    statistics = Defender::Statistics.new
    statistics.api_version.should == "2.0"
    statistics.false_negatives.should == 42
    statistics.false_positives.should == 1
    statistics.learning.should be_true
    statistics.legitimate_total.should == 15
    statistics.recent_accuracy.should == 0.9525
    statistics.unwanted_malicious.should == 2
    statistics.unwanted_spam.should == 5
    statistics.unwanted_total.should == 7
  end

  it "raises a StandardError if the server fails" do
    FakeWeb.register_uri(:get, "http://api.defensio.com/2.0/users/foobar/basic-stats.json",
                         :body => '{"defensio-result":{"api-version":"2.0","status":"failed","message":"Oops"}}',
                         :status => ["500", "Server Error"])

    Defender.api_key = "foobar"
    lambda { Defender::Statistics.new }.should raise_error(StandardError, "Oops")
  end
end
