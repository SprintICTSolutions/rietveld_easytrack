require 'net/sftp'
require 'net/ssh'

require_relative 'exception'

module RietveldEasytrack
  module Connection
    def self.send_file(content, remote_directory, filename)
      self.with_connection do |sftp|
        self.upload_file_atomic(sftp, content, remote_directory, filename)
      end
    end

    def self.send_files(files)
      self.with_connection do |sftp|
        files.each do |file|
          self.upload_file_atomic(sftp, file[:file], file[:path], file[:file_name])
        end
      end
    end

    def self.read_files(remote_directory, from_date = nil)
      from_date = Time.now.to_date.to_s if from_date.nil?

      files = []

      self.with_connection do |sftp|
        file_paths = self.list_newer_files(sftp, remote_directory, from_date)
        file_paths.each do |path|
          files << self.download_file(sftp, path)
        end
      end

      files
    end

    private

    # Uploads a file to the remote atomically using an existing SFTP connection.
    #
    # Initially, the file is uploaded as a hidden file and later moved to
    # prevent Easytrack from processing before upload has finished.
    def self.upload_file_atomic(sftp, content, remote_directory, filename)
      tmp_file = File.join(remote_directory, ".#{filename}")
      dst_file = File.join(remote_directory, filename)

      self.upload_file(sftp, content, tmp_file)
      self.rename_file(sftp, tmp_file, dst_file)
    end

    # List all files in a remote directory modified after the specified date
    # using an existing SFTP connection.
    def self.list_newer_files(sftp, remote_directory, from_date)
      file_paths = []

      self.foreach_entry(sftp, remote_directory) do |entry|
        # Skip non-files.
        next unless entry.file?

        # Skip hidden files.
        next if entry.name.start_with?('.')

        file_path = File.join(remote_directory, entry.name)

        file_attributes = self.stat(sftp, file_path)

        # Skip empty files.
        next if file_attributes.size == 0

        # Skip files modified before or equal to date.
        modification_time = Time.at(file_attributes.mtime)
        next if modification_time <= from_date

        file_paths << file_path
      end

      return file_paths
    end

    # Upload a file to the remote using an existing SFTP connection.
    def self.upload_file(sftp, content, remote_path)
      self.with_exception_context("upload #{remote_path}") do
        io = StringIO.new(content)
        sftp.upload!(io, remote_path)
      end
    end

    # Download a file from the remote path using an existing SFTP connection.
    def self.download_file(sftp, remote_path)
      self.with_exception_context("download #{remote_path}") do
        sftp.download!(remote_path)
      end
    end

    def self.rename_file(sftp, remote_path_old, remote_path_new)
      self.with_exception_context("rename #{remote_path_old} => #{remote_path_new}") do
        sftp.rename!(remote_path_old, remote_path_new)
      end
    end

    def self.stat(sftp, remote_path)
      self.with_exception_context("stat #{remote_path}") do
        sftp.stat!(remote_path)
      end
    end

    def self.foreach_entry(sftp, remote_directory)
      self.with_exception_context("list #{remote_directory}") do
        sftp.dir.foreach(remote_directory) do |entry|
          next if entry.name == '.' || entry.name == '..'
          yield entry
        end
      end
    end

    def self.config
      {
        hostname: RietveldEasytrack.configuration.hostname,
        username: RietveldEasytrack.configuration.username,
        password: RietveldEasytrack.configuration.password,
        port: RietveldEasytrack.configuration.port,
      }
    end

    def self.with_connection
      begin
        config = self.config
        Net::SFTP.start(
          config[:hostname], config[:username],
          :password => config[:password], :port => config[:port]
        ) do |sftp|
          yield sftp
        end
      rescue Net::SSH::AuthenticationFailed
        raise ConnectionException.new('Authentication failed')
      rescue Net::SSH::ConnectionTimeout
        raise ConnectionException.new('Connection timeout')
      rescue ConnectionException
        raise # Exception was already caught, reraise...
      rescue Exception => e
        raise ConnectionException.new("Unhandled exception (#{e.message})", e)
      end
    end

    def self.with_exception_context(context)
      begin
        yield
      rescue Net::SFTP::StatusException => e
        raise ConnectionException.new("No such file or directory in #{context}", e) if e.code == 2
        raise ConnectionException.new("Permission denied in #{context}", e) if e.code == 3
        raise ConnectionException.new("Unhandled SFTP status #{e.code} (#{e.description}) in #{context}", e)
      end
    end
  end
end
