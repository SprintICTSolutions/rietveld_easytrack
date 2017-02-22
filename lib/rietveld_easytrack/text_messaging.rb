module RietveldEasytrack
  module TextMessaging

    def self.send param
      params = text_messaging_params(param)
      template = File.read(File.join(RietveldEasytrack.root, '/lib/rietveld_easytrack/templates/text_messaging.rb'))
      builder = Nokogiri::XML::Builder.new do |xml|
        eval template
      end
      # File.open(File.join(RietveldEasytrack.root, '/tmp/xml.xml'), 'w') do |file|
      #   file.write builder.doc.to_xml
      # end
      RietveldEasytrack::SSH.send_file(builder.doc.to_xml, '/home/erwin/easytrack/integration/to-device/text-messaging/test.xml')
      return builder.doc.to_xml
    end

    def self.parse param
      return param
    end


    def self.test
      self.send({
        operation_id: '1111',
        asset: {
          code: '9999'
        },
        message: {
          code: '444',
          content: 'text message',
          timestamp: '2011-02-01T09:00:00'
        }
      })
    end

    def self.text_messaging_params(params)
      validations = {
        operation_id: 'string',
        asset: {
          code: 'string'
        },
        message: {
          code: 'string',
          content: 'string',
          timestamp: 'string'
        }
      }

      # Validate root
      validate = HashValidator.validate(params, validations)

      raise ArgumentError, validate.errors unless validate.valid?

      params
    end

  end
end
