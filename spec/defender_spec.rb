require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Defender" do
  it "should raise a StandardError if a method fails" do
    lambda do
      Defender.raise_if_error({
        "status" => "fail",
        "message" => "Failed!"
       })
    end.should raise_error(StandardError, "Failed!")
  end
  
  it "should return the correct URL for any given action" do
    d = Defender.new(:api_key => "key1234")
    d.instance_eval do
      url("foobar")
    end.should == "http://api.defensio.com/blog/#{Defender::API_VERSION}/foobar/key1234.yaml"
  end
  
  it "should correctly identify a valid API key" do
    d = Defender.new(:api_key => ENV["API_KEY"], :owner_url => ENV["API_OWNER_URL"])
    d.valid_key?.should be_true
  end
  
  it "should correctly identify an invalid API key" do
    d = Defender.new(:api_key => "key1234", :owner_url => ENV["API_OWNER_URL"])
    d.valid_key?.should be_false
  end
  
  it "should correctly identify a spammy comment" do
    d = Defender.new(:api_key => ENV["API_KEY"], :owner_url => ENV["API_OWNER_URL"])
    
    d.audit_comment(
      :user_ip => "127.0.0.1",
      :article_date => Time.now,
      :comment_author => "Henrik Hodne",
      :comment_type => "comment",
      :test_force => "spam,0.5000"
    ).spam?.should be_true
  end
  
  it "should correctly identify a meaty comment" do
    d = Defender.new(:api_key => ENV["API_KEY"], :owner_url => ENV["API_OWNER_URL"])
    
    d.audit_comment(
      :user_ip => "127.0.0.1",
      :article_date => Time.now,
      :comment_author => "Henrik Hodne",
      :comment_type => "comment",
      :test_force => "ham,0.1000"
    ).spam?.should be_false
  end
  
  it "should correctly set the spaminess" do
    d = Defender.new(:api_key => ENV["API_KEY"], :owner_url => ENV["API_OWNER_URL"])
    
    d.audit_comment(
      :user_ip => "127.0.0.1",
      :article_date => Time.now,
      :comment_author => "Henrik Hodne",
      :comment_type => "comment",
      :test_force => "spam,0.5000"
    ).spaminess.should == 0.5
  end
  
  it "should fail without valid API credentials" do
    d = Defender.new(:api_key => "key1234", :owner_url => "http://google.com")
    
    lambda {
      d.audit_comment(
        :user_ip => "127.0.0.1",
        :article_date => Time.now,
        :comment_author => "Henrik Hodne",
        :comment_type => "comment",
        :test_force => "ham,0.1000"
      )
    }.should raise_error(StandardError, "Authentication failed. Please verify your key/owner-url combination.")
  end
end
