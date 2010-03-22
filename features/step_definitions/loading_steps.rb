Given /^the file config\/config.yml$/ do
  File.exist?("config/config.yml")
end

Given /^a server$/ do
  @server = ThinServer.new
end

When /^loading the file$/ do
  @server.load("config/config.yml")
end

Then /^the server should have a name$/ do
  @server.name
end

Then /^the server should have an ip address$/ do
  @server.address
end

Then /^the server should have a port$/ do
  @server.port
end

Then /^the server should have a path$/ do
  @server.path
end

Then /^the server should have servers$/ do
  @server.servers
end
