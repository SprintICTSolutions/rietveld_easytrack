require 'net/scp'

module RietveldEasytrack
  module SCP

    def self.connect
      Net::SCP.start('vaku3ett.agropro.nl', 'erwin', :ssh => { :password => 'rietveld' })
    end

    def self.send_file(file, remote_path)
      puts file
      puts remote_path
      # self.connect do |conn|
        # conn.upload(StringIO.new(""), remote_path)
      Net::SCP.upload!('vaku3ett.agropro.nl', 'erwin', StringIO.new(file), remote_path, :ssh => { :password => 'rietveld', :port => 56022 })
      # end
    end

    def self.read_file

    end

  end
end
