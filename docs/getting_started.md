## Prerequisites

Caoutsearch requires at least :
* Ruby  >= 2.7.x
* Rails >= 6.x
* Elasticsearch 8.x

## Installation

Add the gem in your Gemfile:

```bash
bundle add caoutsearch
```

## Configuration

Few options are available to configure Caoutsearch:

```ruby
Caoutsearch.configure do |config|
  # Configure how to connect to Elasticsearch.
  #
  # `Elasticsearch::Client` is provided by the elasticsearch gem.
  # See https://www.elastic.co/guide/en/elasticsearch/client/ruby-api/current/connecting.html
  #
  config.client = Elasticsearch::Client.new(
    host:             "https://my-elasticsearch-host.example",
    retry_on_failure: true,
    request_timeout:  30
  )

  # Set defaults settings to apply to every indexes:
  #
  # See https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html#index-modules-settings
  #
  config.settings = {
    number_of_shards:    5,
    number_of_replicas:  2,
    analysis: {
      analyzer: {
        words: { type: :custom, tokenizer: :standard, filter: %i[lowercase word_length] }
      },
      normalizer: {
        lowercase:  { type: :custom, filter: %i[lowercase] },
      },
      filter: {
        word_length: { type: :length, min: 1 },
      }
    }
  }

  # Instrument Elasticsearch requests into your Rails logs.
  # There are three different output:
  #   - 'full'          - Log the full request
  #   - 'truncated'     - Log only the 200 first character of the request
  #   - 'amazing_print' - Pretty print the request body.
  #
  # Instrumentation is not enabled by default.
  # Without argument, 'full' format is used by default.
  # You need to install the amazing_print gem to use the corresponding format.
  #
  config.instrument

  # You can also define alternative configurations to indexes & searches:
  #
  config.index do |index|
    config.instrument :truncated
  end

  config.search do |search|
    search.client = Elasticsearch::Client.new(
      host:            "https://my-elasticsearch-host.example",
      request_timeout: 10
    )

    config.instrument :amazing_print
  end
end
```
