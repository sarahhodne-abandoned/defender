Before do
  Defender.defensio = FakeDefensio.new
end

Given /^I have a hammy comment$/ do
  @comment = Comment.new
  @comment.body = '[innocent,0.1]'
end

Given /^I have a spammy comment$/ do
  @comment = Comment.new
  @comment.body = '[spam,0.9]'
end

Given /^I have submitted a comment$/ do
  @comment = Comment.new
  @comment.body = '[innocent,0.1]'
  @comment.save
end

When /^I save it$/ do
  @comment.save
end

When /^I mark it as a false positive$/ do
  @comment.false_positive!
  @comment.save
end

When /^I mark it as a false negative$/ do
  @comment.false_negative!
  @comment.save
end

When /^I retrieve the document from the server$/ do
  @new_document = Defender::Document.find(@document.signature)
end

Then /^it should be marked as ham$/ do
  @comment.spam?.should be_false
end

Then /^it should be marked as spam$/ do
  @comment.spam?.should be_true
end

Then /^it should have the same data$/ do
  @new_document.spam?.should == @document.allow?
end

Then /^it should have the same signature$/ do
  @new_document.signature.should == @document.signature
end
