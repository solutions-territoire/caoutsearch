# Caoutsearch [\ˈkawt͡ˈsɝtʃ\\](http://ipa-reader.xyz/?text=ˈkawt͡ˈsɝtʃ)

[![Gem Version](https://badge.fury.io/rb/caoutsearch.svg)](https://rubygems.org/gems/caoutsearch)
[![CI Status](https://github.com/mon-territoire/caoutsearch/actions/workflows/ci.yml/badge.svg)](https://github.com/mon-territoire/caoutsearch/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/9bb8b75ea8c66b1a9c94/maintainability)](https://codeclimate.com/github/mon-territoire/caoutsearch/maintainability)

**!! Documentation is under development !!**

Yet another Elasticsearch integration for Ruby and/or Rails.  
Caoutsearch provides a simple but powerful DSL to perform complex indexing and searching,
while securely exposing search criteria to a public API.

If you don't have such complex scenarios, maybe you should look at other awesome gems such as [elasticsearch-rails](https://github.com/elastic/elasticsearch-rails), [search_flip](https://github.com/mrkamel/search_flip) or [searchkick](https://github.com/ankane/searchkick) which will better suite your needs and were an important source of inspiration for this project.

Caoutsearch supports Elasticsearch 8.x only.  
Elasticsearch client and API is provided by the [elasticsearch-ruby](https://github.com/elastic/elasticsearch-ruby) project.

Caoutsearch is used in production in a robust application, updated and maintained for several years at [Mon Territoire](https://mon-territoire.fr).

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
  - Instrumentation
- [Usage](#usage)
  - [Indice Configuration](#indice-configuration)
    - Mapping & settings
    - Text analysis
    - Versionning
  - [Index Engine](#index-engine)
    - Properties
    - Partial updates
    - Eager loading
    - Interdependencies
  - [Search Engine](#search-engine)
    - Queries
    - Filters
    - Full-text query
    - Custom filters
    - Orders
    - Aggregations
    - Transform
    - Responses
    - Loading
  - [Model integration](#model-integration)
    - Add Caoutsearch to your models
    - Index records
      - Index multiple records
      - Index single records
      - Delete documents
      - Automatic Callbacks
    - Search for records
      - Search API
      - Pagination
      - Total count
      - Scroll records

## Installation

```bash
bundle add caoutsearch
```

## Configuration

TODO

## Usage

### Indice Configuration

TODO

### Index Engine

TODO

### Search Engine

TODO

### Model integration

TODO

## Contributing

1. Don't hesitate to submit your feature/idea/fix in [issues](https://github.com/mon-territoire/caoutsearch)
2. Fork the [repository](https://github.com/mon-territoire/caoutsearch)
3. Create your feature branch
4. Ensure RSpec & Rubocop are passing
4. Create a pull request

### Tests & lint

```bash
bundle exec rspec
bundle exec rubocop
```

Both can be run with:

```bash
bundle exec rake
```

## License & credits

Please see [LICENSE](https://github.com/mon-territoire/caoutsearch/blob/main/LICENSE) for further details.

Contributors: [./graphs/contributors](https://github.com/mon-territoire/caoutsearch/graphs/contributors)

