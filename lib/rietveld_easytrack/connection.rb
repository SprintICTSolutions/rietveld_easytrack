require 'net/scp'
require 'net/ssh'
require 'uri/open-scp'

module RietveldEasytrack
  module Connection

    def self.send_file(file, remote_path)
      Net::SCP.upload!(
        'vaku3ett.agropro.nl',
        'erwin',
        StringIO.new(file),
        remote_path,
        :ssh => {
          :password => 'rietveld',
          :port => 56022
        }
      )
      # end
    end

    def self.read_file(path)
      file = open("scp://erwin@vaku3ett.agropro.nl#{path}", :ssh => { :password => 'rietveld', :port => 56022 }).read
    end

    # Returns array of full path file locations in the given dir
    def self.dir_list(dir, date = nil)
      date = Time.now().to_date.to_s if date.nil?
      Net::SSH.start('vaku3ett.agropro.nl', 'erwin', :password => 'rietveld', :port => 56022) do |ssh|
        ssh.exec!("find #{dir} -mindepth 1 -newermt #{date}") do |channel, stream, data|
          return data.split("\n")
        end
      end
    end

    # SCP connection
    def self.connect
      Net::SCP.start('vaku3ett.agropro.nl', 'erwin', :ssh => { :password => 'rietveld' })
    end

  end
end
