# AwsImds

This gem provides access to the AWS Instance Meta Data Service

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws_imds', '~> 0.1.0', git: 'https://github.com/lscheidler/aws_imds'
```

And then execute:

    $ bundle --binstubs bin


## Usage

### With the cli

```
# show help
bin/aws_imds -h

# return meta data as json
bin/aws_imds -m

# return ami_id
bin/aws_imds -m -f ami_id

# return ami_id as json
bin/aws_imds -m -j -f ami_id

# return available categories
bin/aws_imds -c

# return available categories for iam
bin/aws_imds -c iam

# return user data
bin/aws_imds -u
```

### Programmaticly

```ruby
require 'aws_imds'

# get ami_id
p AwsImds.meta_data.ami_id

# get list of available categories
p AwsImds.meta_data.class.categories.keys

# get user data
p AwsImds.user_data
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lscheidler/aws_imds.

## License

The gem is available as open source under the terms of the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0).
