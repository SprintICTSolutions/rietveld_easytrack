require 'net/scp'
require 'net/ssh'
require 'uri/open-scp'

module RietveldEasytrack
  module Connection

    def self.send_file(file, remote_path, secondary = nil)
      begin
        Net::SCP.upload!(
          self.config(secondary)[:hostname],
          self.config(secondary)[:username],
          StringIO.new(file),
          remote_path,
          :ssh => {
            :password => self.config(secondary)[:password],
            :port => self.config(secondary)[:port]
          }
        )
      rescue Net::SSH::AuthenticationFailed
        return 'Authentication failed'
      rescue Net::SSH::ConnectionTimeout
        raise 'Connection timeout' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        return self.send_file(file, remote_path, true)
      rescue Exception => e
        STDERR.puts e
        raise 'Something went wrong' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        STDERR.puts 'Something went wrong, trying secondary server'
        return self.send_file(file, remote_path, true)
      end
    end

    def self.read_file(path, secondary = nil)
      begin
        file = open("scp://#{self.config(secondary)[:username]}@#{self.config(secondary)[:hostname]}#{path}", :ssh => { :password => self.config(secondary)[:password], :port => self.config(secondary)[:port] }).read
      rescue Net::SSH::AuthenticationFailed
        raise 'Authentication failed'
      rescue Net::SSH::ConnectionTimeout
        raise 'Connection timeout' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        return self.read_file(path, true)
      rescue Exception => e
        STDERR.puts e
        raise 'Something went wrong' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        STDERR.puts 'Something went wrong, trying secondary server'
        return self.read_file(path, true)
      end
    end

    # Returns array of full path file locations in the given dir
    def self.dir_list(dir, date = nil, secondary = nil)
      begin
        date = Time.now().to_date.to_s if date.nil?
        all_data = ''
        Net::SSH.start(self.config(secondary)[:hostname], self.config(secondary)[:username], :password => self.config(secondary)[:password], :port => self.config(secondary)[:port]) do |ssh|
          ssh.exec!("find #{dir} -mindepth 1 -newermt #{date}") do |channel, stream, data|
            all_data << data
          end
          return all_data.split("\n")
        end
      rescue Net::SSH::AuthenticationFailed
        return 'Authentication failed'
      rescue Net::SSH::ConnectionTimeout
        raise 'Connection timeout' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        return self.dir_list(dir, date, true)
      rescue Exception => e
        STDERR.puts e
        raise 'Something went wrong' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        STDERR.puts 'Something went wrong, trying secondary server'
        return self.dir_list(dir, date, true)
      end
    end

    def self.config(secondary = nil)
      if secondary
        {
          hostname: RietveldEasytrack.configuration.hostname_secondary,
          username: RietveldEasytrack.configuration.username_secondary,
          password: RietveldEasytrack.configuration.password_secondary,
          port: RietveldEasytrack.configuration.port_secondary
        }
      else
        {
          hostname: RietveldEasytrack.configuration.hostname_primary,
          username: RietveldEasytrack.configuration.username_primary,
          password: RietveldEasytrack.configuration.password_primary,
          port: RietveldEasytrack.configuration.port_primary
        }
      end
    end
  end
end
