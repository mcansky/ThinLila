#!/bin/env ruby
require 'yaml'
require 'optparse'
# Bundle thin starter

# the class to handle the servers
class ThinServer
  attr_accessor :name, :chdir, :address, :port, :socket, :env, :daemonize, :debug, :log, :pid, :user, :group, :servers
  # initialize method
  # yml file syntax :
  #server:
  #  name: one          # optional
  #  address: 0.0.0.0   # mandatory
  #  port: 3000         # mandatory
  #  socket: nil        # optionnal
  #  chdir: /Users/mcansky/Code/arbousier3/arbousierR   # mandatory
  #  env: development   # mandatory
  #  daemonize: true    # optionnal (default : false)
  #  duser: mcansky     # optionnal
  #  dgroup: users      # optionnal
  #  log: /Users/mcansky/Code/arbousier3/arbousierR/log/thin.log  # mandatory
  #  pid: /Users/mcansky/tmp/thin_one.pid     # mandatory
  #  servers: 3         # optionnal (default : 5)
  def initialize(yaml_hash)
    @name = yaml_hash['name']
    @address = yaml_hash['address']
    @port = yaml_hash['port']
    if (yaml_hash['socket'] == 'nil')
      @socket = nil
    else
      @socket = yaml_hash['socket']
    end
    @chdir = yaml_hash['chdir']
    @env = yaml_hash['env']
    @daemonize = yaml_hash['daemonize'] || false
    @duser = yaml_hash['duser']
    @dgroup = yaml_hash['dgroup']
    @log = yaml_hash['log']
    @pid = yaml_hash['pid']
    @servers = yaml_hash['servers'] || 5
    @debug = false
  end

  # return the option string
  def options
    options = Array.new
    options << "-a #{self.address}"
    options << "-p #{self.port}"
    options << "-S #{self.socket}" if self.socket
    options << "-e #{self.env}"
    options << "-d" if self.daemonize
    options << "-l #{self.log}" if self.log
    options << "-P #{self.pid}" if self.pid
    options << "-u #{self.duser}" if self.duser
    options << "-g #{self.dgroup}" if self.dgroup
    options << "-s #{self.servers}"
    options << "-D" if self.debug
    return options.join(" ")
  end

  # start method
  def start
    Dir.chdir(self.chdir)
    system("bundle exec thin #{self.options} start")
  end

  # stop
  def stop
    require 'pathname'
    pid_dir = Pathname.new(self.pid) + ".."
    pid_file_template = self.pid.split('/')[-1].gsub('.pid','')
    count = 0
    pids = Array.new
    while count != self.servers
      pids << pid_dir.to_s + "/#{pid_file_template}.#{self.port + count}.pid"
      count += 1
    end
    pids.each do |d_pid|
      Dir.chdir(self.chdir)
      system("bundle exec thin -P #{d_pid} stop")
    end
  end

  # restart
  def restart
    require 'pathname'
    pid_dir = Pathname.new(self.pid) + ".."
    pid_file_template = self.pid.split('/')[-1].gsub('.pid','')
    count = 0
    pids = Array.new
    while count != self.servers
      pids << pid_dir.to_s + "/#{pid_file_template}.#{self.port + count}.pid"
      count += 1
    end
    pids.each do |d_pid|
      Dir.chdir(self.chdir)
      system("bundle exec thin -P #{d_pid} restart")
    end
  end
end

# handling options
options = Hash.new

optparse = OptionParser.new do |opts|
  # set banner
  opts.banner = "Usage: thin_lila.rb [options]"

  # the config dir
  options[:config_dir] = "config"
  opts.on( '-c', '--config DIR', 'The dir where the yml config files are stored.' ) do |dir|
    options[:config_dir] = dir
  end

  # help
  opts.on( '-h', '--help', 'Display this screen.' ) do
    puts opts
    exit
  end
  
  # dry run
  options[:test] = false
  opts.on('-t', '--test', 'Display the commands that are going to be run') do
    options[:test] = true
  end
  
  # debug / verbose
  options[:debug] = false
  opts.on('-D', '--debug', 'Set debug on.') do
    options[:debug] = true
  end

  # start action
  options[:start] = false
  opts.on('--start', 'Start the servers') do
    options[:start] = true
  end

  # stop action
  options[:stop] = false
  opts.on('--stop', 'Stop the servers') do
    options[:stop] = true
  end

  # restart action
  options[:restart] = false
  opts.on('--restart', 'Restart the servers') do
    options[:restart] = true
  end
end
optparse.parse!

# loading the confs
servers = Array.new
Dir["#{options[:config_dir]}/*.yml"].each do |f|
  servers << ThinServer.new(YAML.load_file(f)["server"])
end

# triggering the commands

if options[:start] && !options[:test]
  servers.each do |s|
    printf("Starting #{s.name} thin server :")
    s.debug = true if options[:debug]
    printf(" -debug on-") if options[:debug]
    if s.start
      printf("\tOK\n")
    else
      printf("\tKO\n")
    end
  end
end

if options[:restart] && !options[:test]
  servers.each do |s|
    printf("Restarting #{s.name} thin server :")
    if s.restart
      printf("\tOK\n")
    else
      printf("\tKO\n")
    end
  end
end

if options[:stop] && !options[:test]
  servers.each do |s|
    printf("Stopping #{s.name} thin server : ")
    if s.stop
      printf("\tOK\n")
    else
      printf("\tKO\n")
    end
  end
end

if options[:test]
  servers.each do |s|
    if options[:start]
      puts "> bundle exec thin #{s.options} start"
    end
    if options[:stop]
    end
  end
end

