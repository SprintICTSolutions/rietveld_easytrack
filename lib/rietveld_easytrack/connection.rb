require 'net/scp'
require 'net/ssh'
require 'uri/open-scp'

module RietveldEasytrack
  module Connection

    def self.send_file(file, remote_path)
      Net::SCP.upload!(
        RietveldEasytrack.configuration.hostname_primary,
        RietveldEasytrack.configuration.username_primary,
        StringIO.new(file),
        remote_path,
        :ssh => {
          :password => RietveldEasytrack.configuration.password_primary,
          :port => RietveldEasytrack.configuration.port_primary
        }
      )
      # end
    end

    def self.read_file(path)
      file = open("scp://#{RietveldEasytrack.configuration.username_primary}@#{RietveldEasytrack.configuration.hostname_primary}#{path}", :ssh => { :password => RietveldEasytrack.configuration.password_primary, :port => RietveldEasytrack.configuration.port_primary }).read
    end

    # Returns array of full path file locations in the given dir
    def self.dir_list(dir, date = nil)
      date = Time.now().to_date.to_s if date.nil?
      Net::SSH.start(RietveldEasytrack.configuration.hostname_primary, RietveldEasytrack.configuration.username_primary, :password => RietveldEasytrack.configuration.password_primary, :port => RietveldEasytrack.configuration.port_primary) do |ssh|
        ssh.exec!("find #{dir} -mindepth 1 -newermt #{date}") do |channel, stream, data|
          return data.split("\n")
        end
      end
    end
  end
end
