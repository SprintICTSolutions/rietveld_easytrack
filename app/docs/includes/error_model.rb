class ErrorModel
  include Swagger::Blocks

  swagger_schema :ErrorModel do
    allOf do
      schema do
        key :'$ref', :ErrorField
      end
    end
  end

  swagger_schema :ErrorField do
    property :field do
      key :type, :array
      items do
        key :'$ref', :ErrorMessage
      end
    end
  end

  swagger_schema :ErrorMessage do
    key :type, :string
  end
end
