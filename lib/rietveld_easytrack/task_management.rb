require 'fileutils'

module RietveldEasytrack
  module TaskManagement

    def self.send_task(param)
      params = task_management_params(param)
      template = File.read(File.join(RietveldEasytrack.root, '/lib/rietveld_easytrack/templates/task_management.rb'))
      builder = Nokogiri::XML::Builder.new do |xml|
        eval template
      end
      RietveldEasytrack::Connection.send_file(builder.doc.to_xml, '/home/erwin/easytrack/integration/to-device/task-management/test.xml')
      # path = File.join(RietveldEasytrack.root, '/tmp')
      # # Create tmp directory if not exists
      # FileUtils.mkdir_p(path) unless File.directory?(path)
      # File.open(File.join(path, '/xml.xml'), 'w') do |file|
      #   file.write builder.doc.to_xml
      # end
      return builder.doc.to_xml
    end

    def self.parse param
      return param
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
