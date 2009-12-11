require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Defender do
  context "api keys" do
    it "returns false when given an invalid API key" do
      Defender.expects(:request).with(:get, "/2.0/users/foobar.yaml", nil).
        returns([404,
                {"status" => "failed", "message" => "API key not found",
                  "api-version" => "2.0", "owner-url" => ""}]
      )
      Defender.api_key = "foobar"
      Defender.check_api_key.should be_false
    end

    it "returns true when given a valid API key" do
      Defender.expects(:request).with(:get, "/2.0/users/barbaz.yaml", nil).
        returns([200,
                {"status" => "success", "message" => "",
                  "api-version" => "2.0", "owner-url" => ""}]
               )
      Defender.api_key = "barbaz"
      Defender.check_api_key.should be_true
    end

    it "raises an error when the server fails" do
      Defender.expects(:request).with(:get, "/2.0/users/foobaz.yaml", nil).
        returns([500,
                {"status" => "failed", "message" => "PHAIL!",
                  "api-version" => "2.0", "owner-url" => ""}]
               )
      Defender.api_key = "foobaz"
      lambda { Defender.check_api_key }.should raise_error(StandardError, "PHAIL!")
    end
  end

  context "requests" do
    it "URL encodes the attributes into the URI in a GET request" do
      Defender.expects(:request).with(:get, "/foobar?this+is=a+test", nil).
        returns(true)
      Defender.get("/foobar", "this is" => "a test").should be_true
    end

    it "passes POST, PUT and DELETE requests on to #request as-is and return the result" do
      Defender.expects(:request).with(:post, "/foo/bar", {"foobar" => "baz"}).returns(true)
      Defender.expects(:request).with(:put, "/foo/bar", {"foobar" => "baz"}).returns(true)
      Defender.expects(:request).with(:delete, "/foo/bar", {"foobar" => "baz"}).returns(true)

      Defender.post("/foo/bar", {"foobar" => "baz"}).should be_true
      Defender.put("/foo/bar", {"foobar" => "baz"}).should be_true
      Defender.delete("/foo/bar", {"foobar" => "baz"}).should be_true
    end

    it "calls the Net::HTTP methods for a GET request without a body" do
      hsh_response = {"foo" => "bar", "foobar" => "baz"}
      http_response = stub(:code => "200", :body => YAML.dump({"defensio-result" => hsh_response}))
      http_object = mock('http') do
        expects(:request).with {|req, body| req.class == Net::HTTP::Get && req.path == "/" && body.nil? }.returns(http_response)
      end
      Net::HTTP.expects(:start).yields(http_object)

      Defender.get("/").should == [200, hsh_response]
    end

    it "calls the Net::HTTP methods for a POST request with a body" do
      hsh_response = {"foo" => "bar", "foobar" => "baz"}
      http_response = stub(:code => "200", :body => YAML.dump({"defensio-result" => hsh_response}))
      http_object = mock('http') do
        expects(:request).with {|req, body|
          req.class == Net::HTTP::Post &&
            req.path == "/post" &&
            (body == "foo=bar&foobar=baz" ||
             "foobar=baz&foo=bar")
        }.returns(http_response)
      end
      Net::HTTP.expects(:start).yields(http_object)

      Defender.post("/post", hsh_response).should == [200, hsh_response]
    end
  end
end
