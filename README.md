# API Template

This project is based on:

1. Api-template https://github.com/SprintICTSolutions/api-template

# Modules

## Task Management

### Template
Located in lib/easy_track/templates/task_management.rb

This is the xml template for a task.

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

