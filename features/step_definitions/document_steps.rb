Before do
  Defender.defensio = FakeDefensio.new
end

Given /^I have a hammy comment$/ do
  @document = Defender::Document.new
  @document.data[:content] = '[innocent,0.1]'
end

Given /^I have a spammy comment$/ do
  @document = Defender::Document.new
  @document.data[:content] = '[spam,0.9]'
end

Given /^it is marked as spam$/ do
  @document.allow = false
end

Given /^it is marked as ham$/ do
  @document.allow = true
end

Given /^I have submitted a document$/ do
  @document = Defender::Document.new
  @document.data[:content] = '[innocent,0.1]'
  @document.save
end

When /^I submit it$/ do
  @document.save
end

When /^I mark it as a false positive$/ do
  @document.allow = true
  @document.save
end

When /^I mark it as a false negative$/ do
  @document.allow = false
  @document.save
end

When /^I retrieve the document from the server$/ do
  @new_document = Defender::Document.find(@document.signature)
end

Then /^it should be marked as ham$/ do
  @document.allow?.should be_true
end

Then /^it should be marked as spam$/ do
  @document.allow?.should be_false
end

Then /^it should have the same data$/ do
  @new_document.data.should == @document.data
end
