# Rietveld Easytrack

# Installation
Add the following line to your Gemfile

```
gem 'rietveld_easytrack', :git => 'https://github.com/SprintICTSolutions/rietveld_easytrack.git'
```

# Usage

## Task Management

### Module functions

#### send_task(params)
Generates a sendable xml file with the given parameters and sends it to the XML Hub.

Parameter format:

```ruby
{
  operation_id: '',
  asset: {
    code: ''
  },
  trip: {
    code: '',
    name: '',
    description: '',
    sequence: '',
    planned_start: '', # Optional
    planned_finish: '', # Optional
    locations: [
      {
         code: '',
         name: '',
         description: '',
         sequence: '',
         address: { # Optional
           street: '',
           zipcode: '',
           city: '',
           country: ''
         },
         contact: { # Optional
           organisation: '', # Optional
           name: '',
           phone_number: ''
         },
         coordinates: { # Optional
           latitude: '',
           longitude: ''
         },
         tasks: [
           {
             code: '',
             name: '',
             description: '',
             type: '',
             sequence: '',
             planned_start: '', # Optional
             planned_finish: '' # Optional
           },
         ]
      },
   ]
}
```

#### read_tasks(from_date)
Reads the available XML files starting from the from_date timestamp, returning the results in an array of hashes with the information.


#### delete_task(params)
Deletes the trip/task with the given trip code.

Parameter format:

```ruby
{
  operation_id: '',
  asset: {
    code: ''
  },
  trip: {
    code: '',
  }
}
```

# Configuration

Configuration must be done in your project

```ruby
RietveldEasytrack.configure do |config|
  config.hostname = ''
  config.username = ''
  config.password = ''
  config.port = ''

  config.text_messages_write_path = ''
  config.text_messages_read_path = ''

  config.task_management_write_path = ''
  config.task_management_read_path = ''

  config.activity_registration_read_path = ''
end
```

The keys are available to you throughout your application as:

```ruby
RietveldEasytrack.configuration.hostname
```

# Development
To override the gem location with a local path use the following command in your project:

```
bundle config local.rietveld_easytrack /local/path
```

Bundler then uses your local git to determine the version, so any new changes to the gem need to be added to a (local) commit.

## local_config.rb
To help set the configuration during development, create the following file: 'lib/local_config.rb'

```ruby
module DevSettings
  def self.set
    RietveldEasytrack.configuration.hostname = ''
    RietveldEasytrack.configuration.username = ''
    RietveldEasytrack.configuration.password = ''
    RietveldEasytrack.configuration.port = ''

    RietveldEasytrack.configuration.text_message_write_path = ''
    RietveldEasytrack.configuration.text_message_read_path = ''

    RietveldEasytrack.configuration.task_management_write_path = ''
    RietveldEasytrack.configuration.task_management_read_path = ''

    RietveldEasytrack.configuration.activity_registration_read_path = ''
  end
end
```

after this the config can be set within your console: DevSettings.set
