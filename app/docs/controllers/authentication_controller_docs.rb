class AuthenticationControllerDocs
  include Swagger::Blocks

  swagger_path '/authenticate' do
    operation :post do
      key :summary, 'Login as a user'
      key :tags, [
        'auth',
      ]

      parameter do
        key :name, :credentials
        key :in, :body
        key :description, 'Login credentials from the user'
        key :required, true
        schema do
          key :'$ref', :LoginPost
        end
      end

      response 200 do
        key :description, 'Logged in'
        schema do
          property :auth_token do
            key :type, :string
            key :format, :string
            key :description, 'Authentication token'
          end
        end
      end

      response 401 do
        key :'$ref', '#/responses/unauthorized'
      end
    end
  end

  swagger_path '/lost_password' do
    operation :post do
      key :summary, 'Lost password, request a new one'
      key :tags, ['auth']

      parameter do
        key :name, :email
        key :in, :query
        key :type, :string
        key :description, 'E-mail'
        key :required, true
      end

      response 204 do
        key :description, 'Password reset requested'
      end
    end
  end

  swagger_path '/change_password' do
    operation :post do
      key :summary, 'Change password'
      key :tags, ['auth']

      parameter do
        key :name, :email
        key :in, :query
        key :type, :string
        key :description, 'E-mail'
        key :required, true
      end

      parameter do
        key :name, :token
        key :in, :query
        key :type, :string
        key :description, 'Token'
        key :required, true
      end

      parameter do
        key :name, :password
        key :in, :query
        key :type, :string
        key :description, 'Password'
        key :required, true
      end

      response 204 do
        key :description, 'Password changed'
      end
    end
  end
end
