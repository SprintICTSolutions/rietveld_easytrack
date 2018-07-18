xml.trip {
  xml.code params[:trip][:code]
  xml.name params[:trip][:name]
  xml.description params[:trip][:description]
  xml.sequence params[:trip][:sequence]
  xml.plannedStart params[:trip][:planned_start] if params[:trip][:planned_start]
  xml.plannedFinish params[:trip][:planned_finish] if params[:trip][:planned_finish]
  xml.locations {
    for location in params[:trip][:locations]
      xml.location{
        xml.code location[:code]
        xml.name location[:name]
        xml.description location[:description]
        xml.sequence location[:sequence] if location[:sequence]
        xml.position {
          if location[:coordinates]
            xml.coordinate {
              xml.latitude location[:coordinates][:latitude]
              xml.longitude location[:coordinates][:longitude]
            }
          end
          if location[:address]
            xml.address {
              xml.street location[:address][:street]
              xml.number location[:address][:number]
              xml.zipcode location[:address][:zipcode]
              xml.city location[:address][:city]
              xml.country location[:address][:country]
            }
          end
        }
        if location[:contact]
          xml.contacts {
            xml.contact {
              xml.name location[:contact][:name]
              xml.phoneNumber location[:contact][:phone_number]
            }
          }
        end
        xml.tasks {
          for task in location[:tasks]
            xml.task {
              xml.code task[:code]
              xml.name task[:name]
              xml.description task[:description]
              xml.taskType task[:type]
              xml.sequence task[:sequence]
              xml.plannedStart task[:planned_start] if task[:planned_start]
              xml.plannedFinish task[:planned_finish] if task[:planned_finish]
            }
          end
        }
      }
    end
  }
}
