module EasyTrack
  module ActivityRegistration

    module_function

    def send param
      template = File.read(Rails.root.join('lib/easy_track/templates/activity_registration.rb'))
      builder = Nokogiri::XML::Builder.new do |xml|
        eval template
      end
      puts builder.doc.errors
      return builder.doc.to_xml
    end

    def parse param
      return param
    end

  end
end
