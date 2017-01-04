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
        tasks: [
          {
            code: '',
            name: '',
            description: '',
            type: '',
            sequence: ''
           },
         ]   
      },  
   ] 
}

```

