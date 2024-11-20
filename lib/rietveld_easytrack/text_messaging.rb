module RietveldEasytrack
  module TextMessaging

    def self.send_message(param)
      params = text_messaging_params(param)
      template = File.read(File.join(RietveldEasytrack.root, '/lib/rietveld_easytrack/templates/text_messaging.rb'))
      builder = Nokogiri::XML::Builder.new do |xml|
        eval template
      end
      RietveldEasytrack::Connection.send_file(builder.doc.to_xml, '/home/erwin/easytrack/integration/to-device/text-messaging', 'test.xml')
      return builder.doc.to_xml
    end

    def self.read_messages(from_date = nil)
      messages = []
      RietveldEasytrack::Connection.read_files('/home/erwin/easytrack/integration/from-device/text-messaging', from_date).each do |file|
        xml = Nokogiri::XML(file)
        xml = xml.remove_namespaces!.root
        xml.xpath('//operation').each do |operation|
          messages << parse(operation)
        end
      end
      messages
    end

    def self.parse(xml)
      parsed_file = {}
      # xml = Nokogiri::XML(file).remove_namespaces!.root
      parsed_file[:asset_code] = xml.at_xpath('//asset/code').content
      parsed_file[:operation_id] = xml.at_xpath('//operationId').content

      # State update message
      message_state = xml.at_xpath('//messageState')
      unless message_state.nil?
        parsed_file[:message_state] = {}
        parsed_file[:message_state][:code] = message_state.at_xpath('//code')&.content
        parsed_file[:message_state][:state] = message_state.at_xpath('//state')&.content
        parsed_file[:message_state][:timestamp] = message_state.at_xpath('//timestamp')&.content
      end

      # Reply message
      message = xml.at_xpath('//send')
      unless message.nil?
        parsed_file[:message] = {}
        parsed_file[:message][:code] = message.at_xpath('//code')&.content
        parsed_file[:message][:content] = message.at_xpath('//content')&.content
        parsed_file[:message][:timestamp] = message.at_xpath('//timestamp')&.content
        parsed_file[:message][:reply_to] = message.at_xpath('//replyTo/code')&.content
      end
      return parsed_file
    end


    def self.test(message)
      self.send_message({
        operation_id: rand.to_s[2..11],
        asset: {
          code: '9999'
        },
        message: {
          code: rand.to_s[2..11],
          content: message,
          timestamp: Time.now.utc.iso8601
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
