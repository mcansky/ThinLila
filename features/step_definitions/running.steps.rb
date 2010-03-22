Given /^a server with the "([^\"]*)" file$/ do |config_file|
  @server = ThinServer.new
  @server.load(config_file)
end

When /^started$/ do
  @server.start
end

Then /^the server should be running$/ do
  @server.check_status
end

Then /^the server should have ([\d+]) instances$/ do |n|
  @server.running_instances(n)
end

Then /^the server should stop$/ do
  @server.stop
end

