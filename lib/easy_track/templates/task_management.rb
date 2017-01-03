xml.operation('xlmns' => 'http://www.easytrack.nl/integration/taskmanagement/2011/02', 'xlmns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance') {
  xml.operationId params[:operation_id]
  xml.asset {
    xml.code params[:asset][:code]
  }
  xml.update {
    xml.trips {
      xml.trip {
        xml.code params[:trip][:code]
        xml.name params[:trip][:name]
        xml.description params[:trip][:description]
        xml.sequence params[:trip][:sequence]
        xml.locations {
          for location in params[:trip][:locations]
            xml.location{
              xml.code location[:code]
              xml.name location[:name]
              xml.description location[:description]
              xml.sequence location[:sequence]
              xml.position {
                xml.address {
                  xml.street location[:address][:street]
                  xml.zipcode location[:address][:zipcode]
                  xml.city location[:address][:city]
                  xml.country location[:address][:country]
                }
              }
              xml.tasks {
                for task in location[:tasks]
                  xml.task {
                    xml.code task[:code]
                    xml.name task[:name]
                    xml.description task[:description]
                    xml.taskType task[:type]
                    xml.sequence task[:sequence]
                  }
                end
              }
            }
          end
        }
      }
    }
  }
}
