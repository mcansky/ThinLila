# the class to handle the servers
class ThinServer
  attr_accessor :name, :chdir, :address, :port, :socket, :env, :daemonize, :debug, :log, :pid, :duser, :dgroup, :servers
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
    #options << "-P #{self.pid}" if self.pid
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
    pid_dir = Pathname.new(self.chdir)
    pid_file_template = "thin"
    count = 0
    pids = Array.new
    while count != self.servers
      pids << pid_dir.to_s + "/tmp/pids/#{pid_file_template}.#{self.port + count}.pid"
      count += 1
    end
    pids.each do |d_pid|
      Dir.chdir(self.chdir)
      system("bundle exec thin -P #{d_pid} stop")
    end
  end

  # restart
  def restart
    self.stop
    self.start
  end
end