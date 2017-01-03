# API Template

This project is based on the following versions:

1. Ruby: 2.3.x
2. Rails: 5.0.1

## Setup

**All commands need to be run from the root folder of the project**

### Git
To use this template as a base for a new project use the following commands:

1. mkdir project-name
2. cd project-name
3. git clone https://github.com/SprintICTSolutions/api-template.git . && rm -rf .git

At this point you have fetched the latest master branch from this repository, from this point you can proceed like you normally would with a new project.

### Bundle
Run the following command to install all the gems `bundle install`, if you don't have bundler installed use the following command to install it `gem install bundler`

### Database config
Make sure a postgresql server is running on your localhost, otherwise change the correct settings in the `config/database.yml` file.

Run the following command to initialize the database: `rails db:setup`

### Run the server/api
Use the following command to run the server `rails s`

### Docs
Documentation and api interaction is handled by swagger, you can find more information about swagger down below.

## Extra Gems
**bcrypt, jwt, simple_command**: Needed for authentication

**swagger-blocks**: generator for swagger docs

**active_model_serializers**: JSON serializers

**kaminari, api-pagination**: Pagination

**rack-attack**: brute-force/ddos protection

**passenger**: passenger webserver for production

**letter_opener**: mail handler for development

## Config
Rename the filename.example.yml files to filename.yml

**swagger.yml**: Fill in the correct hostname (public api url)

**smtp.yml**: SMTP information for production

## Mail

**Development**: In development mode mails are handled by the letter_opener gem. Mails are exported as html in the `/tmp` folder

**Production & Staging**: Mail is sent normally, using the settings from smtp.yml

## Docs/Swagger
Default docs (swagger-ui) url is `<api-url>/docs`

This url redirects you to the correct swagger-ui URL, using the host variable set in swagger.yml as the api url.

Once the page is loaded you first need to authorize your api-calls with the following steps:

1. Click on 'auth'
2. Click on 'POST /authenticate'
3. Fill in the credentials (click on the example and change the info or copy and paste the following) and click 'Try it out!'
`
{
  "email": "demo@demo.com",
 "password": "demo"
}
`
4. Copy the auth_token returned
5. Click 'Authorize' on the top of the page
6. Paste the key in the value field and click 'Authorize'
7. Now you have been authorized and you can use all api-calls

You can find more info about wrinting swagger docs here: https://github.com/fotinakis/swagger-blocks

## Authentication
Has been setup via the following guide: `http://tutorials.pluralsight.com/ruby-ruby-on-rails/token-based-authentication-with-ruby-on-rails-5-api`

Password-reset functionality has been added.

Default seeded info: username: `demo@demo.com` password: `demo`

## Instance variables
`@current_user` contains the user object for the current user

`@filter` contains the filters fetched from params[:filter]

## Environment variables

### Staging & Production
`RELATION_EMAIL` can be set and will be used as the 'from' addres for emailing

`RELATION_EMAIL_CC` can be set and will be used as the 'cc' addres for emailing

## Rack-Attack
Default limitation is 300 requests per 5 minutes per ip.

Limitation for /authenticate is 5 requests per 20 seconds per ip.

Limitation for /authenticate with email parameter present is 5 requests per 20 seconds.


## Redis & Sidekiq

Redis & sidekiq are needed to provide a job queue system in production/staging since the built-in queue system of rails doesn't work with the passenger webserver.

In development the passenger webserver is disabled, so the default system will work.

Redis & sidekiq are installed within the docker container, no further setup needed. The sidekiq initializer contains a setting for the redis url, within the docker container this always is the default url, so configuration should not be needed.


## Docker

### Dockerfile
The Dockerfile makes sure everything that is needed to run the API is installed:

1. Ruby
2. Redis-server
3. Nodejs
4. Gems

It also makes sure everything is launched correctly by:

1. Removing the server.pid file created by rails to prevent the API from not starting up. (Rails throws an error if the file is still present while starting up)
2. Running the migrations
3. Launching the redis server
4. Launching the sidekiq server
5. Launching the rails passenger server

### docker.sh
The docker.sh file is made to simplify the docker container & image management.

**Make sure the settings on top of the file are set correctly for the project**

If a Dockerfile is located the script allows you to build an image, this uses the Dockerfile to build the image.
After the build has finished it will tag the image with the current git commit token and finally it will push it to the docker server.

If no Dockerfile is located the script will only allow you to fetch the image from the docker server.

When the image is fetched or built it will ask if you are ready to (re)start the container.
