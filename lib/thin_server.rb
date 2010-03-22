# the class to handle the servers
class ThinServer
  attr_accessor :name, :chdir, :address, :port, :socket, :env, :daemonize, :debug, :log, :pid, :duser, :dgroup, :servers
  def initialize()
  end

  # initialize method
  # yml file syntax :
  #server:
  #  name: one          # mandatory
  #  address: 0.0.0.0   # mandatory
  #  port: 3000         # mandatory
  #  socket: nil        # optionnal
  #  chdir: /Users/mcansky/Code/arbousier3/arbousierR   # mandatory
  #  env: development   # mandatory
  #  daemonize: true    # optionnal (default : true)
  #  duser: mcansky     # optionnal
  #  dgroup: users      # optionnal
  #  log: log/thin.log  # mandatory
  #  servers: 3         # optionnal (default : 5)
  def load(yaml_file)
    yaml_hash = YAML.load_file(yaml_file)["server"]
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
    @daemonize = yaml_hash['daemonize'] || true
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

  def path
    return self.chdir
  end

  # check the status of the server
  def check_status
    require 'pathname'
    pid_dir = Pathname.new(self.chdir)
    running = false
    count = 0
    pids = Array.new
    while count != self.servers
      pids << pid_dir.to_s + "/tmp/pids/thin.#{self.port + count}.pid"
      count += 1
    end
    pids.each do |pid|
      if File.exist?(pid)
        running = true
      else
        running = false
      end
    end
    return running
  end

  # check if all wanted instances are running
  def running_instances(n)
    return true if self.check_status && self.servers == n
    return false
  end
end