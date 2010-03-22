Given /^a server with the "([^\"]*)" file$/ do |config_file|
  @server = ThinServer.new
  @server.load(config_file)
end

When /^started$/ do
  @server.start
end

Then /^the server should be running$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the server should have 5 instances$/ do
  pending # express the regexp above with the code you wish you had
end
