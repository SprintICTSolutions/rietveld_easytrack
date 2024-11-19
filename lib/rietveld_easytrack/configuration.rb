module RietveldEasytrack
  class Configuration
    attr_accessor :hostname, :username, :password, :port, :text_message_write_path, :text_message_read_path, :task_management_write_path, :task_management_read_path, :activity_registration_read_path

    def initialize
      @hostname = nil
      @username = nil
      @password = nil
      @port = nil

      @text_message_write_path = nil
      @text_message_read_path = nil

      @task_management_write_path = nil
      @task_management_read_path = nil

      @activity_registration_read_path = nil
    end
  end
end
