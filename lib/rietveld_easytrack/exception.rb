module RietveldEasytrack
  class ConnectionException < StandardError
    attr_reader :cause

    def initialize(message = 'Connection failed', cause = nil)
      super(message)
      @cause = cause
    end
  end
end