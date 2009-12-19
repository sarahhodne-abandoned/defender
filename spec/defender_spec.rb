require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender do
  before(:each) do
    FakeWeb.clean_registry
  end

  context "api keys" do
    it "returns false when given an invalid API key" do
      FakeWeb.register_uri(:get, "http://api.defensio.com/2.0/users/foobar.json",
                           :body => '{"defensio-result":{"status":"failed","message":"API key not found","api-version":"2.0","owner-url":""}}',
                          :status => ['404', 'Not Found'])
      Defender.api_key = "foobar"
      Defender.check_api_key.should be_false
    end

    it "returns true when given a valid API key" do
      FakeWeb.register_uri(:get, "http://api.defensio.com/2.0/users/barbaz.json",
                           :body => '{"defensio-result":{"status":"success","message":"","api-version":"2.0","owner-url":""}}')
      Defender.api_key = "barbaz"
      Defender.check_api_key.should be_true
    end
  end
end
