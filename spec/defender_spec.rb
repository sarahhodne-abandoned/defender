require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender do
  before(:each) do
    Defender.api_key = "foobar"
    @defensio = Defender.defensio
  end
  
  context "api keys" do
    it "returns false when given an invalid API key" do
      @defensio.expects(:get_user).returns(
        [404, {
          "status" => "failed", 
          "message" => "API key not found",
          "api-version" => "2.0",
          "owner-url" => ""
        }])
      Defender.check_api_key.should be_false
    end

    it "returns true when given a valid API key" do
      @defensio.expects(:get_user).returns(
        [200, {
          'status' => 'success', 
          'message' => '',
          'api-version' => '2.0',
          'owner-url' => ''
        }])
      Defender.check_api_key.should be_true
    end
  end
end
