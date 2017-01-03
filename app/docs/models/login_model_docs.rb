class LoginModelDocs
  include Swagger::Blocks

  swagger_schema :LoginPost do
    key :required, [:email, :password]

    property :email do
      key :type, :string
      key :format, :email
      key :description, 'E-mail to use for login.'
    end

    property :password do
      key :type, :string
      key :format, :password
      key :description, 'Password to use for login.'
    end
  end
end
