require "rietveld_easytrack/version"
require "nokogiri"
require "hash_validator"

require "rietveld_easytrack/task_management"

module RietveldEasytrack
  def self.root
    File.expand_path('../..',__FILE__)
  end
end
