require 'net/scp'
require 'net/ssh'
require 'uri/open-scp'

module RietveldEasytrack
  module Connection

    def self.send_file(file, remote_path, file_name, secondary = nil)
      begin
        file_total = 0
        file_sent = 0

        tmp_file = "#{remote_path}.#{file_name}"
        dest_file = "#{remote_path}#{file_name}"

        Net::SSH.start(
          self.config(secondary)[:hostname],
          self.config(secondary)[:username],
          :password => self.config(secondary)[:password],
          :port => self.config(secondary)[:port]
        ) do |ssh|
          # ssh.exec!("touch #{remote_path} && chmod 200 #{remote_path}")

          ssh.scp().upload!(
            StringIO.new(file),
            tmp_file
          ) do |ch, name, sent, total|
            STDOUT.puts "\r#{name}: #{sent}/#{total}"
            file_sent = sent
            file_total = total
          end

          # After upload rename file (ready for processing)
          ssh.exec!("mv #{tmp_file} #{dest_file}")
        end

      rescue Net::SSH::AuthenticationFailed
        return 'Authentication failed'
      rescue Net::SSH::ConnectionTimeout
        raise 'Connection timeout' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        return self.send_file(file, remote_path, file_name, true)
      rescue Exception => e
        STDERR.puts e
        raise 'Something went wrong' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        STDERR.puts 'Something went wrong, trying secondary server'
        return self.send_file(file, remote_path, file_name, true)
      end
    end

    def self.send_files(files, secondary = nil)
      begin
        Net::SSH.start(
          self.config(secondary)[:hostname],
          self.config(secondary)[:username],
          :password => self.config(secondary)[:password],
          :port => self.config(secondary)[:port]
        ) do |ssh|
          files.each do |file|
            file_total = 0
            file_sent = 0

            remote_path = file[:path]
            file_name = file[:file_name]
            file = file[:file]

            tmp_file = "#{remote_path}.#{file_name}"
            dest_file = "#{remote_path}#{file_name}"

            ssh.scp().upload!(
              StringIO.new(file),
              tmp_file
            ) do |ch, name, sent, total|
              STDOUT.puts "\r#{name}: #{sent}/#{total}"
              file_sent = sent
              file_total = total
            end

            # After upload rename file (ready for processing)
            ssh.exec!("mv #{tmp_file} #{dest_file}")
          end
        end

      rescue Net::SSH::AuthenticationFailed
        return 'Authentication failed'
      rescue Net::SSH::ConnectionTimeout
        raise 'Connection timeout' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        return self.send_files(files, true)
      rescue Exception => e
        STDERR.puts e
        raise 'Something went wrong' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        STDERR.puts 'Something went wrong, trying secondary server'
        return self.send_files(files, true)
      end
    end

    def self.read_files(path, date = nil, secondary = nil)
      begin
        date = Time.now().to_date.to_s if date.nil?
        files = []
        Net::SSH.start(self.config(secondary)[:hostname], self.config(secondary)[:username], :password => self.config(secondary)[:password], :port => self.config(secondary)[:port]) do |ssh|
          file_names = self.dir_list(path, date, ssh)
          file_names.each do |fn|
            files << self.read_file(fn, ssh)
          end
          return files
        end
      rescue Net::SSH::AuthenticationFailed
        return 'Authentication failed'
      rescue Net::SSH::ConnectionTimeout
        raise 'Connection timeout' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        return self.read_files(path, date, true)
      rescue Exception => e
        STDERR.puts e
        raise 'Something went wrong' if secondary || (self.config(true)[:hostname].nil? || self.config(true)[:hostname].empty?)
        STDERR.puts 'Something went wrong, trying secondary server'
        return self.read_files(path, date, true)
      end
    end

    def self.read_file(path, ssh_connection)
      ssh_connection.scp.download!(path)
    end

    # Returns array of full path file locations in the given dir
    def self.dir_list(dir, date = nil, ssh_connection)
      all_data = ''
      ssh_connection.exec!("find #{dir} -mindepth 1 -newermt '#{date}'") do |channel, stream, data|
        all_data << data
      end
      return all_data.split("\n")
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
