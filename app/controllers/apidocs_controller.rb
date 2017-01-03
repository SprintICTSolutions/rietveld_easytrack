class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '0.0.1'
      key :title, 'Template API'
      key :description, 'Template API'
      contact do
        key :name, 'Sprint ICT'
      end
    end

    key :host, Rails.configuration.x.swagger.host
    key :schemes, Rails.configuration.x.swagger.schemes
    key :basePath, Rails.configuration.x.swagger.base_path
    key :consumes, ['application/json']
    key :produces, ['application/json']

    security_definition :api_key do
      key :type, :apiKey
      key :name, :Authorization
      key :in, :header
    end

    parameter :filter do
      key :name, :filter
      key :type, :string
      key :in, :query
      key :description, 'JSON string with name/value pairs, the field to filter on and the value to use.'
      key :required, false
    end

    parameter :page do
      key :name, :page
      key :type, :string
      key :in, :query
      key :description, 'Page number to fetch.'
      key :required, false
    end

    parameter :per_page do
      key :name, :per_page
      key :type, :string
      key :in, :query
      key :description, 'Number of results per page.'
      key :required, false
    end

    parameter :csv do
      key :name, :csv
      key :type, :boolean
      key :in, :query
      key :description, 'Boolean to toggle normal JSON data or CSV file export.'
      key :required, false
    end

    response :unauthorized do
      key :description, 'Not logged in'
      schema do
        key :'$ref', :ErrorModel
      end
    end

    response :unprocessable_entity do
      key :description, 'Something went wrong.'
      schema do
        key :'$ref', :ErrorModel
      end
    end
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    AuthenticationControllerDocs,
    LoginModelDocs,
    BaseModel,
    ErrorModel,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
