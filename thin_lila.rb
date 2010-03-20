#!/bin/env ruby
require 'lib/thin_server'
require 'yaml'
require 'optparse'
# Bundle thin starter

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

  # list the servers
  options[:list] = false
  opts.on('-l', '--list', 'List the servers') do
    options[:list] = true
  end

  # only act on one server
  options[:name] = nil
  opts.on('-n', '--name NAME', 'Act on a particular server') do |name|
    server = nil
    servers.each do |s|
      if s.name == name
        server = s
      end
    end
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
config_servers = Array.new
Dir["#{options[:config_dir]}/*.yml"].each do |f|
  config_servers << ThinServer.new(YAML.load_file(f)["server"])
end

# triggering the commands
servers = Array.new
servers << server if options[:name]
servers = config_servers unless options[:name]

if options[:list]
  servers.each do |s|
    puts "#{s.name} #{s.address}:#{s.port} (#{s.servers} servers)"
  end
end

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

