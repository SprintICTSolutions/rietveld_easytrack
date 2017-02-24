# Rietveld Easytrack

# Installation
Add the following line to your Gemfile

```
gem 'rietveld_easytrack', :git => 'https://github.com/SprintICTSolutions/rietveld_easytrack.git'
```

# Usage

## Task Management

### Module functions

#### send(param)
Generates a sendable xml file with the given parameters.

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
         address: {
           street: '',
           zipcode: '',
           city: '',
           country: ''
         },
         coordinates: {
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

# Configuration

Configuration must be done in your project

```ruby
RietveldEasytrack.configure do |config|
  config.hostname_primary = ''
  config.username_primary = ''
  config.password_primary = ''
  config.port_primary = ''

  config.hostname_secondary = ''
  config.username_secondary = ''
  config.password_secondary = ''
  config.port_secondary = ''

  config.text_messages_write_path = ''
  config.text_messages_read_path = ''

  config.task_management_write_path = ''
  config.task_management_read_path = ''
end
```

The keys are available to you throughout your application as:

```ruby
RietveldEasytrack.configuration.hostname_primary
```

# Development
To override the gem location with a local path use the following command in your project:

```
bundle config local.rietveld_easytrack /local/path
```

Bundler then uses your local git to determine the version, so any new changes to the gem need to be added to a (local) commit.
