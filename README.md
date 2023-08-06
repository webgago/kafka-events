# Kafka::Events

[![Gem Version](https://badge.fury.io/rb/kafka-events.svg)](https://badge.fury.io/rb/kafka-events)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/webgago/kafka-events/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/webgago/kafka-events/tree/main)
[![Coverage Status](https://coveralls.io/repos/github/webgago/kafka-events/badge.svg)](https://coveralls.io/github/webgago/kafka-events)
[![Maintainability](https://api.codeclimate.com/v1/badges/60b75840d88b7646bd73/maintainability)](https://codeclimate.com/github/webgago/kafka-events/maintainability)
[![License](https://img.shields.io/github/license/webgago/kafka-events)](https://github.com/webgago/kafka-events/blob/main/LICENSE)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "kafka-events"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install kafka-events

## Usage

### Configuration

```ruby
  Kafka::Events.configure do |config|
    config.base_contract_class = Events::Contract
    config.validate_keys = false # default is true 
    
    # see https://dry-rb.org/gems/dry-validation/1.10/macros/
    config.macros.register(:email_format) do
      key.failure('not a valid email format') if value !~ /^.+@.+\..+/
    end
  end
```

### Defining Events

```ruby
  class Events::User::Create < Kafka::Events::Base
    topic "users"
    type "user.created"
    key { |event| event.payload.email }
    
    service Events::Service::CreateUser

    produces Events::Notification::UserCreated
    produces Events::DripCampaign::Start, optional: true
    
    payload_schema do
      attribute :email, Types::String
      attribute :name, Types::String
    end
  
    headers_schema do
      attribute :event_id, Types::String
      attribute? :event_type, Types::String
      attribute? :event_time, Types::String
    end
  
    context_schema do
      attribute :user, Types::Instance(User)
    end

    payload do |context, payload|
      {
        name: context.user.name,
        email: context.user.email,
        **payload
      }
    end

    rules do
      rule(payload: :email).validate(:email_format)
    end
  end
```

### Creating Events

There are 2 ways to create events.
First, when you have a context object and want to create an event from it.
This is useful when you have a model or another object that comes as a source for the event.
In this case you must define 2 pieces in your event. The context schema and the payload generator block.

```ruby
# structure for Events::User::Create::Context
context_schema do
  attribute :user, Types::Instance(User)
end

# context is an instance of Events::User::Create::Context
payload do |context, payload|
  { name: context.user.name, email: context.user.email, **payload }  
end
```

Then, you can create the event from the context object.

```ruby
  Events::User::Create.context(user: user).headers(event_id: SecureRandom.uuid).to_h
# => {
#   value: { type: "user.created", name: "John Doe", email: "user@example" },
#   headers: { event_id: "edc8dc25-ecdf-4198-958c-976fbbb30ca8" },
#   topic: "users",
#   key: "user@example"
# }
```

### How to use Kafka::Events::Service

Service is a class that is responsible for handling the business logic and producing new events.

```ruby
  class Events::Service::CreateUser < Kafka::Events::Service
    def call
      user = User.create!(name: event.name, email: event.email)
      produce Events::User::Created.context(user: user).headers(event_id: SecureRandom.uuid)
      produce Events::DripCampaign::Start.context(user: user) if user.drip_campaign?
    end
  end
```

### Consuming Events from a Rails request or Grape API request

To consume events from a request, you can use the `Kafka::Events::Job` class.

`Kafka::Events::Job` responsible for event and produced events validation.
If the validation fails, it will raise a `Kafka::Events::ProduceEventError` or `Kafka::Events::SchemaValidationError`
If the validation passes, it will return the produced events and you can send them to Kafka using `waterdrop` gem.


```ruby
class Events::Job < Kafka::Events::Job
  option :producer, default: proc { DeliverEventsService }
end

# params and headers come from the request
#   params #=> { type: "user.created", name: "John Doe", email: "user@example" }
#   headers #=> { "X-Kafka-Event-ID": "edc8dc25-ecdf-4198-958c-976fbbb30ca8" }
post "/users" do
  # events is an array of Kafka::Events::KafkaMessage
  events = Events::Job.new(params: params, headers: headers).perform
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kafka-events. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/kafka-events/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kafka::Events project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/kafka-events/blob/main/CODE_OF_CONDUCT.md).
