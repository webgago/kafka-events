# Kafka::Events

[![Gem Version](https://badge.fury.io/rb/kafka-events.svg)](https://badge.fury.io/rb/kafka-events)
[![Build Status](https://travis-ci.com/abhishekkr/kafka-events.svg?branch=main)](https://travis-ci.com/abhishekkr/kafka-events)
[![codecov](https://codecov.io/gh/abhishekkr/kafka-events/branch/main/graph/badge.svg?token=ZQZQZQZQZQ)](https://codecov.io/gh/abhishekkr/kafka-events)
[![Maintainability](https://api.codeclimate.com/v1/badges/60b75840d88b7646bd73/maintainability)](https://codeclimate.com/github/webgago/kafka-events/maintainability)
[![License](https://img.shields.io/github/license/webgago/kafka-events)](https://github.com/webgago/kafka-events/blob/main/LICENSE)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kafka-events'
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
      key.failure('not a valid email format')
    end
  end
```

### Defining Events

```ruby
  class Events::User::Create < Kafka::Events::Base
    topic "users"
    type "user.created"

    service Events::Service::CreateUser

    produces Events::Notification::UserCreated
    produces Events::DripCampaign::Start, optional: true
    
    payload_schema do
      attribute :email, Types::String
      attribute :name, Types::String
    end
  
    headers_schema do
      attribute :event_id, Types::String
      attribute :event_type, Types::String
      attribute :event_time, Types::String
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

```ruby
  class Events::Service::CreateUser < Kafka::Events::Service
    def call
      user = User.create!(name: event.name, email: event.email)
      produce Events::User::Created.context(user: user).headers(event_id: SecureRandom.uuid)
      produce Events::DripCampaign::Start.context(user: user) if user.drip_campaign?
    end
  end
```

### Consuming Events

```ruby
  Kafka::Events::Job.new(type: "user.created", params: params, headers: headers).perform
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
