module RietveldEasytrack
  class Configuration
    attr_accessor :hostname_primary, :username_primary, :password_primary, :port_primary, :hostname_secondary, :username_secondary, :password_secondary, :port_secondary, :text_message_write_path, :text_message_read_path, :task_management_write_path, :task_management_read_path

    def initialize
      @hostname_primary = nil
      @username_primary = nil
      @password_primary = nil
      @port_primary = nil

      @hostname_secondary = nil
      @username_secondary = nil
      @password_secondary = nil
      @port_secondary = nil

      @text_message_write_path = nil
      @text_message_read_path = nil

      @task_management_write_path = nil
      @task_management_read_path = nil
    end
  end
end
