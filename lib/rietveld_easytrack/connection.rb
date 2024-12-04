require 'pathname'

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
      from_date = Time.now if from_date.nil?

      files = []

      self.with_connection do |sftp|
        self.organize_new_files(sftp, remote_directory)

        file_paths = self.list_organized_files(sftp, remote_directory, from_date)
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

    def self.mkdir(sftp, remote_directory)
      self.with_exception_context("mkdir #{remote_directory}") do
        self.split_path(remote_directory)
            .inject('/') do |parent, filename|
          path = File.join(parent, filename)

          begin
            sftp.stat!(path)
          rescue Net::SFTP::StatusException => e
            raise unless e.code == Net::SFTP::Constants::StatusCodes::FX_NO_SUCH_FILE
            sftp.mkdir!(path)
          end

          path
        end
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

    # Moves new files to a YEAR/MONTH/DAY/HOUR directory structure based on their modification time.
    def self.organize_new_files(sftp, remote_directory)
      self.foreach_entry(sftp, remote_directory) do |entry|
        filename = entry.name

        self.with_exception_context("structure #{filename}") do
          # Skip non-files.
          next unless entry.file?

          # Skip hidden files.
          next if filename.start_with?('.')

          src_path = File.join(remote_directory, filename)

          file_attributes = self.stat(sftp, src_path)

          # Skip empty files.
          next if file_attributes.size == 0

          modification_time = Time.at(file_attributes.mtime)

          group_directory = File.join(
            remote_directory,
            modification_time.year.to_s,
            modification_time.month.to_s,
            modification_time.day.to_s,
            modification_time.hour.to_s
          )

          self.mkdir(sftp, group_directory)

          dst_path = File.join(group_directory, filename)

          self.rename_file(sftp, src_path, dst_path)
        end
      end
    end

    # Recursively lists all files modified later than the specified date given a YEAR/MONTH/DAY/HOUR
    # directory structure.
    def self.list_organized_files(sftp, remote_directory, from_date)
      self.with_exception_context("structured list #{remote_directory}") do
        self.list_directories_matching_regex(sftp, remote_directory, /\A\d{4}\z/).flat_map do |year_path|
          year = File.basename(year_path).to_i
          next unless year >= from_date.year

          list_organized_files_by_year(sftp, remote_directory, year, from_date)
        end.compact
      end
    end

    def self.list_organized_files_by_year(sftp, remote_directory, year, from_date)
      year_path = File.join(remote_directory, year.to_s)

      self.list_directories_matching_regex(sftp, year_path, /\A\d{,2}\z/).flat_map do |month_path|
        month = File.basename(month_path).to_i
        next unless year > from_date.year || month >= from_date.month

        self.list_organized_files_by_month(sftp, remote_directory, year, month, from_date)
      end.compact
    end

    def self.list_organized_files_by_month(sftp, remote_directory, year, month, from_date)
      month_path = File.join(remote_directory, year.to_s, month.to_s)

      self.list_directories_matching_regex(sftp, month_path, /\A\d{,2}\z/).flat_map do |day_path|
        day = File.basename(day_path).to_i
        next unless year > from_date.year || month > from_date.month || day >= from_date.day

        self.list_organized_files_by_day(sftp, remote_directory, year, month, day, from_date)
      end.compact
    end

    def self.list_organized_files_by_day(sftp, remote_directory, year, month, day, from_date)
      day_path = File.join(remote_directory, year.to_s, month.to_s, day.to_s)

      self.list_directories_matching_regex(sftp, day_path, /\A\d{,2}\z/).flat_map do |hour_path|
        hour = File.basename(hour_path).to_i
        next unless year > from_date.year || month > from_date.month || day > from_date.day || hour >= from_date.hour

        self.list_organized_files_by_hour(sftp, remote_directory, year, month, day, hour, from_date)
      end.compact
    end

    def self.list_organized_files_by_hour(sftp, remote_directory, year, month, day, hour, from_date)
      hour_path = File.join(remote_directory, year.to_s, month.to_s, day.to_s, hour.to_s)

      # Perform simple, inexpensive list for all directories past the given from date.
      if year > from_date.year || month > from_date.month || day > from_date.day || hour > from_date.hour
        self.list_files(sftp, hour_path)
      else
        self.list_newer_files(sftp, hour_path, from_date)
      end
    end

    # Lists all files in a directory modified after and including the given date.
    #
    # A client-side stat is required for every file in the directory, therefore
    # this operation is expensive for directories with a lot of files.
    def self.list_newer_files(sftp, remote_directory, from_date)
      paths = []

      self.foreach_entry(sftp, remote_directory) do |entry|
        # Skip non-files.
        next unless entry.file?

        # Skip hidden files.
        next if entry.name.start_with?('.')

        file_path = File.join(remote_directory, entry.name)

        file_attributes = self.stat(sftp, file_path)

        # Skip files modified before or equal to date.
        modification_time = Time.at(file_attributes.mtime)
        next if modification_time <= from_date

        paths << file_path
      end

      paths.sort!
    end

    # Lists all files in a directory.
    def self.list_files(sftp, remote_directory)
      paths = []

      self.foreach_entry(sftp, remote_directory) do |entry|
        # Skip non-files.
        next unless entry.file?

        # Skip hidden files.
        next if entry.name.start_with?('.')

        file_path = File.join(remote_directory, entry.name)

        paths << file_path
      end

      paths.sort!
    end

    def self.list_directories_matching_regex(sftp, remote_directory, filename_regex)
      filenames = []

      self.foreach_entry(sftp, remote_directory) do |entry|
        # Skip non-directories.
        next unless entry.directory?

        # Skip hidden files.
        next if entry.name.start_with?('.')

        # Skip non-matching files.
        next unless filename_regex.match?(entry.name)

        filenames << entry.name
      end

      filenames.sort!
    end

    def self.split_path(path)
      Pathname.new(path).each_filename.to_a
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
