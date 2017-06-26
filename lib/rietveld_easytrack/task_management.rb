require 'fileutils'

module RietveldEasytrack
  module TaskManagement

    def self.send_task(tasks)
      raise ArgumentError, 'Data invalid, please check your data' if tasks.empty?
      # Make sure tasks is an array
      tasks = Array(tasks)

      template = File.read(File.join(RietveldEasytrack.root, '/lib/rietveld_easytrack/templates/task_management.rb'))
      xml = Nokogiri::XML('<?xml version = "1.0" encoding = "UTF-8" standalone ="no"?>')

      xml_tasks = ''

      tasks.each do |params|
        params = task_management_params(params)
        builder = Nokogiri::XML::Builder.new do |xml|
          eval template
        end
        xml_tasks << builder.doc.root.to_xml
      end

      xml_tasks = "<operationBatch xmlns=\"http://www.easytrack.nl/integration/taskmanagement/2011/02\">#{xml_tasks}</operationBatch>" if tasks.length > 1

      xml << xml_tasks

      RietveldEasytrack::Connection.send_file(xml.to_xml, RietveldEasytrack.configuration.task_management_write_path, "tasks_#{Time.now.iso8601.to_s}.xml")
      return xml.to_xml
    end

    def self.read_tasks(from_date = nil)
      tasks = []
      dir = RietveldEasytrack::Connection.read_files(RietveldEasytrack.configuration.task_management_read_path, from_date)
      dir ||= []
      dir.each do |file|
        xml = Nokogiri::XML(file)
        xml = xml.remove_namespaces!.root
        xml.xpath('//operation').each do |operation|
          tasks << parse(operation)
        end
        xml.xpath('//operationResult').each do |operation|
          tasks << parse(operation)
        end
      end
      tasks
    end

    def self.read_tasks_to_device(from_date = nil)
      tasks = []
      sub_dir = '/processed'
      dir = RietveldEasytrack::Connection.read_files(RietveldEasytrack.configuration.task_management_write_path + sub_dir, from_date)
      dir ||= []
      dir.each do |file|
        xml = Nokogiri::XML(file)
        xml = xml.remove_namespaces!.root
        xml.xpath('//operation').each do |operation|
          tasks << parse_to_device(operation)
        end
      end
      tasks
    end

    def self.delete_task(params)
      params = task_management_delete_params(params)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.operation('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation' => 'http://www.easytrack.nl/integration/taskmanagement/2011/02 ../../resources/xsd/task-management-201102-easytrack.xsd',
          'xmlns' => 'http://www.easytrack.nl/integration/taskmanagement/2011/02') {
          xml.operationId params[:operation_id]
          xml.asset {
            xml.code params[:asset][:code]
          }
          xml.delete {
            xml.trip {
              xml.code params[:trip][:code]
            }
          }
        }
      end
      RietveldEasytrack::Connection.send_file(builder.doc.to_xml, RietveldEasytrack.configuration.task_management_write_path, 'test.xml')
      return builder.doc.to_xml
    end

    def self.parse(xml)
      parsed_file = {}

      parsed_file[:raw_data] = xml.to_xml
      parsed_file[:operation_id] = xml.at_xpath('.//operationId').content
      parsed_file[:asset_code] = xml.at_xpath('.//asset/code').content

      if xml.at_xpath('//asset/children') && xml.at_xpath('//asset/children/child/asset/type').content == 'PERSON'
        parsed_file[:asset_code_driver] = xml.at_xpath('//asset/children/child/asset/code').content
      end

      if xml.xpath('.//trips/statesTrip').any?
        # Trip states
        parsed_file[:trips] = []
        xml.xpath('.//trips/statesTrip').each do |t|
          trip = {}
          trip[:trip_id] = t.at_xpath('.//code').content if t.at_xpath('.//code')
          trip[:location_id] = t.at_xpath('.//statesLocation/code').content if t.at_xpath('.//statesLocation/code')
          trip[:task_id] = t.at_xpath('.//statesTask/code').content if t.at_xpath('.//statesTask/code')

          trip[:states] = []
          t.xpath('.//states/state').each do |s|
            state = {}
            state[:state] = s.at_xpath('.//stateValue').content if s.at_xpath('.//stateValue')
            state[:timestamp] = s.at_xpath('.//timestamp').content if s.at_xpath('.//timestamp')
            state[:position] = {}
            state[:kilometrage] = s.at_xpath('.//kilometrage').content if s.at_xpath('.//kilometrage')

            address = s.at_xpath('.//position/address')
            if address
              state[:position][:street] = address.at_xpath('.//street').content if address.at_xpath('.//street')
              state[:position][:number] = address.at_xpath('.//number').content if address.at_xpath('.//number')
              state[:position][:zipcode] = address.at_xpath('.//zipcode').content if address.at_xpath('.//zipcode')
              state[:position][:city] = address.at_xpath('.//city').content if address.at_xpath('.//city')
              state[:position][:country] = address.at_xpath('.//country').content if address.at_xpath('.//country')
              state[:position][:latitude] = address.at_xpath('.//coordinate/latitude').content if address.at_xpath('.//coordinate/latitude')
              state[:position][:longitude] = address.at_xpath('.//coordinate/longitude').content if address.at_xpath('.//coordinate/longitude')
            end
            trip[:states] << state

            if s.at_xpath('.//questionnaireReport')
              q = s.xpath('.//questionnaireReport')

              questionnaire = {}

              questionnaire[:questionnaireId] = q.at_xpath('.//questionnaireId').content if q.at_xpath('.//questionnaireId')
              questionnaire[:questionnaireVersion] = q.at_xpath('.//questionnaireVersion').content if q.at_xpath('.//questionnaireVersion')
              questionnaire[:timestamp] = q.at_xpath('.//timestamp').content if q.at_xpath('.//timestamp')
              questionnaire[:questionnaireVersion] = q.at_xpath('.//questionnaireVersion').content if q.at_xpath('.//questionnaireVersion')

              questionnaire[:answers] = []

              q.xpath('.//answer').each do |a|
                answer = {}

                answer[:questionId] = a.at_xpath('.//questionId').content if a.at_xpath('.//questionId')
                answer[:answerValue] = a.at_xpath('.//answerValue').content if a.at_xpath('.//answerValue')

                questionnaire[:answers] << answer
              end

              trip[:questionnaireReport] = questionnaire
            end

          end

          parsed_file[:trips] << trip
        end
      else
        parsed_file[:timestamp] = xml.at_xpath('.//timestamp').content if xml.at_xpath('.//timestamp')
        parsed_file[:result] = xml.at_xpath('.//result').content if xml.at_xpath('.//result')
      end


      return parsed_file
    end

    def self.parse_to_device(xml)
      parsed_file = {}

      parsed_file[:raw_data] = xml.to_xml
      parsed_file[:operation_id] = xml.at_xpath('.//operationId').content
      parsed_file[:asset_code] = xml.at_xpath('.//asset/code').content

      if xml.at_xpath('//asset/children') && xml.at_xpath('//asset/children/child/asset/type').content == 'PERSON'
        parsed_file[:asset_code_driver] = xml.at_xpath('//asset/children/child/asset/code').content
      end

      if xml.xpath('.//trips/trip').any?
        # Trips
        parsed_file[:trips] = []
        xml.xpath('.//trips/trip').each do |t|
          trip = {}
          trip[:trip_id] = t.at_xpath('.//code').content if t.at_xpath('.//code')
          trip[:name] = t.at_xpath('.//name').content if t.at_xpath('.//name')
          trip[:description] = t.at_xpath('.//description').content if t.at_xpath('.//description')
          trip[:sequence] = t.at_xpath('.//sequence').content if t.at_xpath('.//sequence')

          trip[:locations] = []
          t.xpath('.//locations/location').each do |l|
            location = {}
            location[:location_id] = l.at_xpath('.//code').content if l.at_xpath('.//code')
            location[:name] = l.at_xpath('.//name').content if l.at_xpath('.//name')
            location[:description] = l.at_xpath('.//description').content if l.at_xpath('.//description')
            location[:position] = {}
            address = l.at_xpath('.//position/address')
            location[:position][:street] = address.at_xpath('.//street').content if address.at_xpath('.//street')
            location[:position][:number] = address.at_xpath('.//number').content if address.at_xpath('.//number')
            location[:position][:zipcode] = address.at_xpath('.//zipcode').content if address.at_xpath('.//zipcode')
            location[:position][:city] = address.at_xpath('.//city').content if address.at_xpath('.//city')
            location[:position][:country] = address.at_xpath('.//country').content if address.at_xpath('.//country')
            location[:position][:latitude] = address.at_xpath('.//coordinate/latitude').content if address.at_xpath('.//coordinate/latitude')
            location[:position][:longitude] = address.at_xpath('.//coordinate/longitude').content if address.at_xpath('.//coordinate/longitude')

            location[:contacts] = []
            l.xpath('.//contacts/contact').each do |c|
              contact = {}
              contact[:name] = c.at_xpath('.//name').content if c.at_xpath('.//name')
              contact[:phoneNumber] = c.at_xpath('.//phoneNumber').content if c.at_xpath('.//phoneNumber')
              location[:contacts] << contact
            end

            trip[:locations] << location
          end

          parsed_file[:trips] << trip
        end
      else
        parsed_file[:timestamp] = xml.at_xpath('.//timestamp').content if xml.at_xpath('.//timestamp')
        parsed_file[:result] = xml.at_xpath('.//result').content if xml.at_xpath('.//result')
      end

      parsed_file[:kilometrage] = xml.at_xpath('.//kilometrage').content if xml.at_xpath('.//kilometrage')

      return parsed_file
    end

    def self.test
      self.send_task([{
        operation_id: rand.to_s[2..40],
        asset: {
          code: '9999'
        },
        trip: {
          code: rand.to_s[2..50],
          name: 'Opdracht 15/09/2015 nr 572243',
          description: 'Vertrek om 16:25 uur Vertrek klant 17:20 uur',
          sequence: 10,
          # planned_start: '2017-02-23T12:00:00',
          # planned_finish: '2017-02-23T13:00:00',
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
              contact: {
                organisation: 'AgroPro',
                name: 'John Doe',
                phone_number: '0123456789'
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
                  sequence: 10
                  # planned_start: '2017-02-23T12:00:00',
                  # planned_finish: '2017-02-23T13:00:00'
                }
              ]
            },
          ]
        }
      }])
    end

    def self.test_delete(trip_code)
      self.delete_task({
        operation_id: rand.to_s[2..40],
        asset: {
          code: '9999'
        },
        trip: {
          code: trip_code.to_s,
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
          # planned_start: 'string',
          # planned_finish: 'string',
          locations: 'array'
        }
      }

      location_validations = {
        code: 'string',
        name: 'string',
        description: 'string',
        sequence: 'integer',
        # address: {
        #   street: 'string',
        #   zipcode: 'string',
        #   city: 'string',
        #   country: 'string'
        # },
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
        # planned_start: 'string',
        # planned_finish: 'string'
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

    def self.task_management_delete_params(params)
      validations = {
        operation_id: 'string',
        asset: {
          code: 'string'
        },
        trip: {
          code: 'string',
        }
      }

      # Validate root
      validate = HashValidator.validate(params, validations)

      raise ArgumentError, validate.errors unless validate.valid?

      params
    end

  end
end
