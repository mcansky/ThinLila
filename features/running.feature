Feature: Run a server
  In order to check if a server is running
  Run the server and check

Scenario: a running server
  Given a server with the "config/config.yml" file
  When started
  Then the server should be running
  And the server should have 5 instances
	And the server should stop