class BaseModel
  include Swagger::Blocks

  swagger_schema :Timestamps do
    key :required, [:created_at, :updated_at]

    property :created_at do
      key :type, :string
      key :format, :'date-time'
      key :description, :'The timestamp of when the object was created'
    end
    property :updated_at do
      key :type, :string
      key :format, :'date-time'
      key :description, :'The timestamp of when the object was last changed'
    end
  end
end
