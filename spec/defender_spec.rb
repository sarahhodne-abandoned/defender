require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender do
  context "Users" do
    it "returns false when given an invalid API key" do
      Defender.stubs(:request).with(:get, "/2.0/users/foobar.yaml", nil).
        returns([404,
                {"status" => "failed", "message" => "API key not found",
                  "api-version" => "2.0", "owner-url" => ""}]
      )
      Defender.api_key = "foobar"
      Defender.check_api_key.should be_false
    end

    it "returns true when given a valid API key" do
      Defender.stubs(:request).with(:get, "/2.0/users/barbaz.yaml", nil).
        returns([200,
                {"status" => "success", "message" => "",
                  "api-version" => "2.0", "owner-url" => ""}]
               )
      Defender.api_key = "barbaz"
      Defender.check_api_key.should be_true
    end
  end
end
