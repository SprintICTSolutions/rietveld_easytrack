module RietveldEasytrack
  module TaskManagement

    def self.send param
      params = task_management_params(param)
      template = File.read('./lib/rietveld_easytrack/templates/task_management.rb')
      builder = Nokogiri::XML::Builder.new do |xml|
        eval template
      end
      File.open('./xml.xml', 'w') do |file|
        file.write builder.doc.to_xml
      end
      return builder.doc.to_xml
    end

    def self.parse param
      return param
    end


    def self.test
      self.send({
        operation_id: 'e797e01d-871e-46d7-9120-f0651fedb8a6',
        asset: {
          code: '8888'
        },
        trip: {
          code: '96f017e7-cd10-490f-984c-fecbcf7661aa',
          name: 'Opdracht 15/09/2015 nr 572243',
          description: 'Vertrek om 16:25 uur Vertrek klant 17:20 uur',
          sequence: '10',
          locations: [
            {
              code: 'dc608c2b-46f0-4934-a5dc-3222fe9ac8de',
              name: 'OP* ECT DELTA  DDW ROTTERDAM',
              description: 'Containertype 20 box
                            Zegelnummer Ffgv
                            Rederij K-LINE
                            Afhaal referentie KKFU 771604-2
                            Dossier 294001
                            Adres ECT DELTA  DDW, EUROPAWEG 875, 3199 LD  ROTTERDAM, NEDERLAND',
              sequence: '10',
              address: {
                street: 'EUROPAWEG 875',
                zipcode: '3199 LD',
                city: 'Rotterdam',
                country: 'NL'
              },
              tasks: [
                {
                  code: '5d3968ac-8b4e-4b40-a7cc-358b70acf9f7',
                  name: 'TR.294001',
                  description: 'Containertype 20 box
                                Zegelnummer Ffgv
                                Rederij K-LINE
                                Afhaal referentie KKFU 771604-2
                                Dossier 294001
                                Adres ECT DELTA  DDW, EUROPAWEG 875, 3199 LD  ROTTERDAM, NEDERLAND',
                  type: '49',
                  sequence: '10'
                },
              ]
            },
          ]
        }
      })
    end

    def self.task_management_params(params)
      return params
      params = ActionController::Parameters.new(params)
      params.require(:operation_id)
      params.require(:asset)
      params.require(:trip).require(:locations)
      params.permit(
        :operation_id,
        :asset => [:code],
        :trip => [
          :code,
          :name,
          :description,
          :sequence,
          :locations => [
            :code,
            :name,
            :description,
            :sequence,
            :address => [
              :street,
              :zipcode,
              :city,
              :country
            ],
            :tasks => [
              :code,
              :name,
              :description,
              :type,
              :sequence
            ]
          ]
        ]
      )
    end

  end
end
