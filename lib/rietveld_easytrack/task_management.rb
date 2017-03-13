require 'fileutils'

module RietveldEasytrack
  module TaskManagement

    def self.send_task(param)
      params = task_management_params(param)
      template = File.read(File.join(RietveldEasytrack.root, '/lib/rietveld_easytrack/templates/task_management.rb'))
      builder = Nokogiri::XML::Builder.new do |xml|
        eval template
      end
      RietveldEasytrack::Connection.send_file(builder.doc.to_xml, RietveldEasytrack.configuration.task_management_write_path + 'test.xml')
      return builder.doc.to_xml
    end

    def self.read_tasks(from_date = nil)
      tasks = []
      RietveldEasytrack::Connection.dir_list(RietveldEasytrack.configuration.task_management_read_path, from_date).each do |filename|
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

      parsed_file[:operation_id] = xml.at_xpath('//operationId').content
      parsed_file[:asset_code] = xml.at_xpath('//asset/code').content
      if xml.at_xpath('//asset/children/child/asset/type').content == 'PERSON'
        parsed_file[:asset_code_driver] = xml.at_xpath('//asset/children/child/asset/code').content
      end

      # Trip states
      parsed_file[:trips] = []
      xml.xpath('//trips/statesTrip').each do |t|
        trip = {}
        trip[:trip_code] = t.at_xpath('.//code').content if t.at_xpath('.//code')
        trip[:location_code] = t.at_xpath('.//statesLocation/code').content if t.at_xpath('.//statesLocation/code')
        trip[:task_code] = t.at_xpath('.//statesTask/code').content if t.at_xpath('.//statesTask/code')

        trip[:states] = []
        t.xpath('.//states/state').each do |s|
          state = {}
          state[:state] = s.at_xpath('.//stateValue').content if s.at_xpath('.//stateValue')
          state[:timestamp] = s.at_xpath('.//timestamp').content if s.at_xpath('.//timestamp')
          state[:position] = {}
          address = s.at_xpath('.//position/address')
          state[:position][:street] = address.at_xpath('.//street').content if address.at_xpath('.//street')
          state[:position][:number] = address.at_xpath('.//number').content if address.at_xpath('.//number')
          state[:position][:zipcode] = address.at_xpath('.//zipcode').content if address.at_xpath('.//zipcode')
          state[:position][:city] = address.at_xpath('.//city').content if address.at_xpath('.//city')
          state[:position][:country] = address.at_xpath('.//country').content if address.at_xpath('.//country')
          state[:position][:latitude] = address.at_xpath('.//coordinate/latitude').content if address.at_xpath('.//coordinate/latitude')
          state[:position][:longitude] = address.at_xpath('.//coordinate/longitude').content if address.at_xpath('.//coordinate/longitude')
          trip[:states] << state
        end

        parsed_file[:trips] << trip
      end
      return parsed_file
    end


    def self.test
      self.send({
        operation_id: rand.to_s[2..40],
        asset: {
          code: '9999'
        },
        trip: {
          code: rand.to_s[2..50],
          name: 'Opdracht 15/09/2015 nr 572243',
          description: 'Vertrek om 16:25 uur Vertrek klant 17:20 uur',
          sequence: 10,
          planned_start: '2017-02-23T12:00:00',
          planned_finish: '2017-02-23T13:00:00',
          locations: [
            {
              code: rand.to_s[2..50],
              name: 'OP* ECT DELTA  DDW ROTTERDAM',
              description: 'Containertype 20 box
                            Zegelnummer Ffgv
                            Rederij K-LINE
                            Afhaal referentie KKFU 771604-2
                            Dossier 294001
                            Adres ECT DELTA  DDW, EUROPAWEG 875, 3199 LD  ROTTERDAM, NEDERLAND',
              sequence: 10,
              address: {
                street: 'EUROPAWEG 875',
                zipcode: '3199 LD',
                city: 'Rotterdam',
                country: 'NL'
              },
              tasks: [
                {
                  code: rand.to_s[2..50],
                  name: 'TR.294001',
                  description: 'Containertype 20 box
                                Zegelnummer Ffgv
                                Rederij K-LINE
                                Afhaal referentie KKFU 771604-2
                                Dossier 294001
                                Adres ECT DELTA  DDW, EUROPAWEG 875, 3199 LD  ROTTERDAM, NEDERLAND',
                  type: 40,
                  sequence: 10,
                  planned_start: '2017-02-23T12:00:00',
                  planned_finish: '2017-02-23T13:00:00'
                }
              ]
            },
          ]
        }
      })
    end

    def self.task_management_params(params)
      validations = {
        operation_id: 'string',
        asset: {
          code: 'string'
        },
        trip: {
          code: 'string',
          name: 'string',
          description: 'string',
          sequence: 'integer',
          planned_start: 'string',
          planned_finish: 'string',
          locations: 'array'
        }
      }

      location_validations = {
        code: 'string',
        name: 'string',
        description: 'string',
        sequence: 'integer',
        address: {
          street: 'string',
          zipcode: 'string',
          city: 'string',
          country: 'string'
        },
        # coordinates: {
        #   longitude: 'string',
        #   latitude: 'string'
        # },
        tasks: 'array'
      }

      task_validations = {
        code: 'string',
        name: 'string',
        description: 'string',
        type: 'integer',
        sequence: 'integer',
        planned_start: 'string',
        planned_finish: 'string'
      }

      # Validate root
      validate = HashValidator.validate(params, validations)

      raise ArgumentError, validate.errors unless validate.valid?

      # Validate locations
      params[:trip][:locations].each do |loc|
        validate_location = HashValidator.validate(loc, location_validations)
        # Validate tasks
        loc[:tasks].each do |task|
          validate_task = HashValidator.validate(task, task_validations)
          next if validate_task.valid?
          raise ArgumentError, {:tasks => validate_task.errors}
        end
        next if validate_location.valid?
        raise ArgumentError, {:locations => validate_location.errors}
      end


      params
    end

  end
end
