module RietveldEasytrack
  module ActivityRegistration

    def self.read_activities(from_date = nil)
      tasks = []
      RietveldEasytrack::Connection.dir_list(RietveldEasytrack.configuration.activity_registration_read_path, from_date).each do |filename|
        xml = Nokogiri::XML(RietveldEasytrack::Connection.read_file(filename))
        xml = xml.remove_namespaces!.root
        xml.xpath('//operation').each do |operation|
          tasks << parse(operation)
        end
      end
      tasks
    end

    def self.parse(xml)
      parsed_file = {}

      parsed_file[:raw_data] = xml.to_xml
      parsed_file[:operation_id] = xml.at_xpath('.//operationId').content
      parsed_file[:asset_code] = xml.at_xpath('.//asset/code').content

      # activity state
      as = xml.xpath('.//update/activityState')

      parsed_file[:activity_code] = as.at_xpath('.//code').content if as.at_xpath('.//code')
      parsed_file[:activity_type] = as.at_xpath('.//activityType').content if as.at_xpath('.//activityType')
      parsed_file[:activity_state] = as.at_xpath('.//activityState').content if as.at_xpath('.//activityState')
      parsed_file[:timestamp] = as.at_xpath('.//timestamp').content if as.at_xpath('.//timestamp')

      address = as.at_xpath('.//position/address')
      coordinates = as.at_xpath('.//position/coordinate')
      parsed_file[:position] = {}
      if address
        parsed_file[:position][:street] = address.at_xpath('.//street').content if address.at_xpath('.//street')
        parsed_file[:position][:number] = address.at_xpath('.//number').content if address.at_xpath('.//number')
        parsed_file[:position][:zipcode] = address.at_xpath('.//zipcode').content if address.at_xpath('.//zipcode')
        parsed_file[:position][:city] = address.at_xpath('.//city').content if address.at_xpath('.//city')
        parsed_file[:position][:country] = address.at_xpath('.//country').content if address.at_xpath('.//country')
        parsed_file[:position][:latitude] = address.at_xpath('.//coordinate/latitude').content if address.at_xpath('.//coordinate/latitude')
        parsed_file[:position][:longitude] = address.at_xpath('.//coordinate/longitude').content if address.at_xpath('.//coordinate/longitude')
      elsif coordinates
        parsed_file[:position][:latitude] = coordinates.at_xpath('.//latitude').content if coordinates.at_xpath('.//latitude')
        parsed_file[:position][:longitude] = coordinates.at_xpath('.//longitude').content if coordinates.at_xpath('.//longitude')
      end

      return parsed_file
    end
  end
end
