Feature: Load a server config from a yaml file
	In order to load a server config
	I want to get the vars needed

Scenario: A yaml file
	Given the file config/config.yml
	And a server
	When loading the file
	Then the server should have a name
	And the server should have an ip address
	And the server should have a port
	And the server should have a path
	And the server should have servers
	And the server should have a log
	And the server should have an environment