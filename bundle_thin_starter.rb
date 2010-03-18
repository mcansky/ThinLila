#!/bin/env ruby
require 'yaml'
# Bundle thin starter

# the class to handle the servers
class ThinServer
  # initialize method
  # yml file syntax :
  #server:
  #  name: one
  #  address: 0.0.0.0
  #  port: 3000
  #  socket: nil
  #  chdir: /Users/mcansky/Code/arbousier3/arbousierR
  #  env: development
  #  daemonize: true
  #  duser: mcansky
  #  dgroup: users
  #  log: /Users/mcansky/Code/arbousier3/arbousierR/log/thin.log
  #  pid: /Users/mcansky/tmp/thin_one.pid
  #  servers: 3
  def initialize(yaml_hash)
    @name = yaml_hash['name']
    @address = yaml_hash['address']
    @port = yaml_hash['port']
    @socket = yaml_hash['socket']
    @chdir = yaml_hash['chdir']
    @env = yaml_hash['env']
    @daemonize = yaml_hash['daemonize']
    @duser = yaml_hash['duser']
    @dgroup = yaml_hash['dgroup']
    @log = yaml_hash['log']
    @pid = yaml_hash['pid']
    @servers = yaml_hash['servers']
  end
end

servers = Array.new
Dir['config/*.yml'].each do |f|
  servers << ThinServer.new(YAML.load_file(f)["server"])
end
puts servers.inspect

