# Caoutsearch [\ˈkawt͡ˈsɝtʃ\\](http://ipa-reader.xyz/?text=ˈkawt͡ˈsɝtʃ)

[![Gem Version](https://badge.fury.io/rb/caoutsearch.svg)](https://rubygems.org/gems/caoutsearch)
[![CI Status](https://github.com/mon-territoire/caoutsearch/actions/workflows/ci.yml/badge.svg)](https://github.com/mon-territoire/caoutsearch/actions/workflows/ci.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Maintainability](https://api.codeclimate.com/v1/badges/fbe73db3fd8be9a10e12/maintainability)](https://codeclimate.com/github/mon-territoire/caoutsearch/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/fbe73db3fd8be9a10e12/test_coverage)](https://codeclimate.com/github/mon-territoire/caoutsearch/test_coverage)

[![JRuby](https://github.com/mon-territoire/caoutsearch/actions/workflows/jruby.yml/badge.svg)](https://github.com/mon-territoire/caoutsearch/actions/workflows/jruby.yml)
[![Truffle Ruby](https://github.com/mon-territoire/caoutsearch/actions/workflows/truffle_ruby.yml/badge.svg)](https://github.com/mon-territoire/caoutsearch/actions/workflows/truffle_ruby.yml)

**!! Gem under development before public release !!**

Caoutsearch is a new Elasticsearch integration for Ruby and/or Rails.  
It provides a simple but powerful DSL to perform complex indexing and searching, while securely exposing search criteria to a public and chainable API, without overwhelming your models.

Caoutsearch only supports Elasticsearch 8.x right now.  
It is used in production in a robust application, updated and maintained for several years at [Mon Territoire](https://mon-territoire.fr).

Caoutsearch was inspired by awesome gems such as [elasticsearch-rails](https://github.com/elastic/elasticsearch-rails) or [search_flip](https://github.com/mrkamel/search_flip). 
If you don't have scenarios as complex as those described in this documentation, they should better suite your needs.

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
    - [Filters](#filters)
    - Full-text query
    - Custom filters
    - Orders
    - Aggregations
    - Transform
    - [Responses](#responses)
    - [Loading records](#loading-records)
  - [Model integration](#model-integration)
    - [Add Caoutsearch to your models](#add-caoutsearch-to-your-models)
    - [Index records](#index-records)
      - [Index multiple records](#index-multiple-records)
      - [Index single records](#index-single-records)
      - [Delete documents](#delete-documents)
      - [Automatic Callbacks](#automatic-callbacks)
      - Asynchronous methods
    - [Search for records](#search-for-records)
      - [Search API](#search-api)
      - [Pagination](#pagination)
      - [Total count](#total-count)
      - [Iterating results](#iterating-results)
  - [Testing with Caoutsearch](#testing-with-Caoutsearch)

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

#### Filters
Filters declared in the search engine will define how Caoutsearch will build the queries 

The main use of filters is to expose a field for search, but they can also be used to build more complex queries:
```ruby
class ArticleSearch < Caoutsearch::Search::Base
  # Build a filter on the author field
  filter :author

  # Build a Match filter on multiple fields
  filter :content,      indexes: %i[title.words content], as: :match
  
  # Build a more complex filter by using other filters
  filter :public,       as: :boolean
  filter :published_on, as: :date
  filter :active do |value|
    search_by(published: value, published_on: value)
  end
end
```

Caoutsearch different types of filters to handle different types of data or ways to search them:

##### Default filter

##### Boolean filter

##### Date filter

For a date filter defined like this:
```ruby
class ArticleSearch < Caoutsearch::Search::Base
  ...

  filter :published_on, as: :date
end
```

You can now search the matching index with the `published_on` criterion:
```ruby
Article.search(published_on: Date.today)
```

and the following query will be generated to send to elasticsearch:
```json
{
  "query": { 
    "bool": { 
      "filter": [ 
        { "range": { "published_on": { "gte": "2022-23-11", "lte": "2022-23-11"}}}
      ]
    }
  }
}
```

The date filter accepts multiple types of arguments :

```ruby
# Search for articles published on a date:
Article.search(published_on: Date.today)

# Search for articles published before a date:
Article.search(published_on: { less_than: "2022-12-25" })
Article.search(published_on: { less_than_or_equal: "2022-12-25" })
Article.search(published_on: ..Date.new(2022, 12, 25))
Article.search(published_on: [[nil, "now-2w/d"]])

# Search for articles published after a date:
Article.search(published_on: { greater_than: "2022-12-25" })
Article.search(published_on: { greater_than_or_equal: "2022-12-25" })
Article.search(published_on: Date.new(2022, 12, 25)..)
Article.search(published_on: [["now-1w/d", nil]])

# Search for articles published between two dates:
Article.search(published_on: { greater_than: "2022-12-25", less_than: "2023-12-25" })
Article.search(published_on: Date.new(2022, 12, 25)..Date.new(2023, 12, 25))
Article.search(published_on: [["now-1w/d", "now/d"]])
```

Dates of various formats are handled:
```ruby
"2022-10-11"
Date.today
Time.zone.now
```

We also support elasticsearch's date math
```ruby
"now-1h"
"now+2w/d"
```

##### GeoPoint filter

##### Match filter

##### Range filter

#### Responses

After the request has been sent by calling a method such as `load`, `response` or `hits`, the results is wrapped in a `Response::Response` class which provides method access to its properties via [Hashie::Mash](http://github.com/intridea/hashie).

Aggregations and suggestions are wrapped in their own respective subclass of `Response::Response`

````ruby
results.response
=> #<Caoutsearch::Response::Response _shards=#<Caoutsearch::Response::Response failed=0 skipped=0 successful=5 total=5> hits=…

search.hits
=> #<Hashie::Array [#<Caoutsearch::Response::Response _id="2"…

search.aggregations
=> #<Caoutsearch::Response::Aggregations view_count=#<Caoutsearch::Response::Response…

search.suggestions
=> #<Caoutsearch::Response::Suggestions tags=#<Caoutsearch::Response::Response…
````

##### Loading records

When calling `records`, the search engine will try to load records from a model using the same class name without `Search` the suffix:  
* `ArticleSearch` > `Article`
* `Blog::ArticleSearch` > `Blog::Article`

````ruby
ArticleSearch.new.records.first
# ArticleSearch Search (10ms / took 5ms)
# Article Load (9.6ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" IN (1, …
=> #<Article id: 1, …>
````

However, you can define an alternative model to load records. This might be helpful when using [single table inheritance](https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html).

````ruby
ArticleSearch.new.records(use: BlogArticle).first
# ArticleSearch Search (10ms / took 5ms)
# BlogArticle Load (9.6ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" IN (1, …
=> #<BlogArticle id: 1, …>
````

You can also define an alternative model at class level:

````ruby
class BlogArticleSearch < Caoutsearch::Search::Base
  self.model_name = "Article"

  default do
    query.filters << { term: { category: "blog" } }
  end
end

BlogArticleSearch.new.records.first
# BlogArticleSearch Search (10ms / took 5ms)
# Article Load (9.6ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" IN (1, …
=> #<Article id: 1, …>
````

### Model integration

#### Add Caoutsearch to your models

The simplest solution is to add `Caoutsearch::Model` to your model and the link the appropriate `Index` and/or `Search` engines:

```ruby
class Article < ActiveRecord::Base
  include Caoutsearch::Model

  index_with ArticleIndex
  search_with ArticleSearch
end
```

If you don't need your models to be `Indexable` and `Searchable`, you can include only one of the following two modules:

````ruby
class Article < ActiveRecord::Base
  include Caoutsearch::Model::Indexable

  index_with ArticleIndex
end
````
or
````ruby
class Article < ActiveRecord::Base
  include Caoutsearch::Model::Searchable

  search_with ArticleSearch
end
````

The modules can be safely included in the meta model `ApplicationRecord`.
Indexing & searching features are not available until you call `index_with` or `search_with`:

````ruby
class ApplicationRecord < ActiveRecord::Base
  include Caoutsearch::Model
end
````

#### Index records

##### Index multiple records

Import all your records or a restricted scope of records to Elastcisearch.

````ruby
Article.reindex
Article.where(published: true).reindex
````

You can update one or more properties. (see [Indexation Engines](#indexation-engines) to read more about properties):

````ruby
Article.reindex(:category)
Article.reindex(%i[category published_on])
````

When `reindex` is called without properties, it'll import the full document to ES.  
On the contrary, when properties are passed, it'll only update existing documents.  
You can control this behavior with the `method` argument.

````ruby
Article.where(id: 123).reindex(:category)
# ArticleIndex Reindex {"index":"articles","body":[{"update":{"_id":123}},{"doc":{"category":"blog"}}]}
# [Error] {"update"=>{"_index"=>"articles", "_id"=>"123", "status"=>404, "error"=>{"type"=>"document_missing_exception", …}}

Article.where(id: 123).reindex(:category, method: :index)
# ArticleIndex Reindex {"index":"articles","body":[{"index":{"_id":123}},{"category":"blog"}]}

Article.where(id: 123).reindex(method: :update)
# ArticleIndex Reindex {"index":"articles","body":[{"update":{"_id":123}},{"doc":{…}}]}
````

##### Index single records

Import a single record.

````ruby
Article.find(123).update_index
````

You can update one or more properties. (see [Indexation Engines](#indexation-engines) to read more about properties):

````ruby
Article.find(123).update_index(:category)
Article.find(123).update_index(%i[category published_on])
````

You can verify if and how documents are indexed.  
If the document is missing in ES, it'll raise a `Elastic::Transport::Transport::Errors::NotFound`.

````ruby
Article.find(123).indexed_document
# Traceback (most recent call last):
#         1: from (irb):1
# Elastic::Transport::Transport::Errors::NotFound ([404] {"_index":"articles","_id":"123","found":false})

Article.find(123).update_index
Article.find(123).indexed_document
=> {"_index"=>"articles", "_id"=>"123", "_version"=>1"found"=>true, "_source"=>{…}}
````

##### Delete documents

You can delete one or more documents.  
**Note**: it won't delete records from database, only from the ES indice.

````ruby
Article.delete_indexes
Article.where(id: 123).delete_indexed_documents
Article.find(123).delete_index
````

If a record is already deleted from the database, you can still delete its document.

````ruby
Article.delete_index(123)
````

##### Automatic Callbacks

Callbacks are not provided by Caoutsearch but they are very easy to add:

````ruby
class Article < ApplicationRecord
  index_with ArticleIndex
  
  after_commit :update_index, on: %i[create update]
  after_commit :delete_index, on: %i[destroy]
end
````

##### Asynchronous methods

TODO

#### Search for records

##### Search API
Searching is pretty simple.

````ruby
Article.search("Quick brown fox")
=> #<ArticleSearch current_criteria: ["Quick brown fox"]>
````

You can chain criteria and many other parameters:
````ruby
Article.search("Quick brown fox").search(published: true)
=> #<ArticleSearch current_criteria: ["Quick brown fox", {"published"=>true}]>

Article.search("Quick brown fox").order(:publication_date)
=> #<ArticleSearch current_criteria: ["Quick brown fox"], current_order: :publication_date>

Article.search("Quick brown fox").limit(100).offset(100)
=> #<ArticleSearch current_criteria: ["Quick brown fox"], current_limit: 100, current_offset: 100>

Article.search("Quick brown fox").page(1).per(100)
=> #<ArticleSearch current_criteria: ["Quick brown fox"], current_page: 1, current_limit: 100>

Article.search("Quick brown fox").aggregate(:tags).aggregate(:dates)
=> #<ArticleSearch current_criteria: ["Quick brown fox"], current_aggregations: [:tags, :dates]>>
````

##### Pagination

Search results can be paginated.
````ruby
search = Article.search("Quick brown fox").page(1).per(100)
search.current_page
=> 1

search.total_pages
=> 2546

> search.total_count
=> 254514
````

##### Total count

By default [ES doesn't return the total number of hits](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html#track-total-hits). So, when calling `total_count` or `total_pages` a second request might be sent to ES.  
To avoid a second roundtrip, use `track_total_hits`:

````ruby 
search = Article.search("Quick brown fox")
search.hits
# ArticleSearch Search {…}
# ArticleSearch Search (81.8ms / took 16ms)
=> […]

search.total_count
# ArticleSearch Search {…, track_total_hits: true }
# ArticleSearch Search (135.3ms / took 76ms)
=> 276

search = Article.search("Quick brown fox").track_total_hits
search.hits
# ArticleSearch Search {…, track_total_hits: true }
# ArticleSearch Search (120.2ms / took 56ms)
=> […]

search.total_count
=> 276
````

##### Iterating results

Several methods are provided to loop through a collection or hits or records.  
These methods are processing batches in the most efficient way: [PIT search_after](https://www.elastic.co/guide/en/elasticsearch/reference/current/paginate-search-results.html#search-after).

* `find_each_hit` to yield each hit returned by Elasticsearch.
* `find_each_record` to yield each record from your database.
* `find_hits_in_batches` to yield each batch of hits as returned by Elasticsearch.
* `find_records_in_batches` to yield each batch of records from the database.

Example:

```ruby
Article.search(published: true).find_each_record do |record|
  record.inspect
end
```

The `keep_alive` parameter tells Elasticsearch how long it should keep the point in time alive. Defaults to 1 minute.

```ruby
Article.search(published: true).find_each_record(keep_alive: "2h")
```

To specifies the size of the batch, use `per` chainable method or `batch_size` parameter. Defaults to 1000.

```ruby
Article.search(published: true).find_records_in_batches(batch_size: 500)
Article.search(published: true).per(500).find_records_in_batches
```

## Testing with Caoutsearch

Caoutsearch offers few methods to stub Elasticsearch requests.  
You first need to add [webmock](https://github.com/bblimke/webmock) to your Gemfile.

```bash
bundle add webmock
```

Then, add `Caoutsearch::Testing::MockRequests` to your test suite.  
The examples below uses RSpec, but it should be compatible with other test framework.

```ruby
# spec/spec_helper.rb

require "caoutsearch/testing"

RSpec.configure do |config|
  config.include Caoutsearch::Testing::MockRequests
end
```

You can then call the following methods:

```ruby
RSpec.describe SomeClass do
  before do
    stub_elasticsearch_request(:head, "articles").to_return(status: 200)

    stub_elasticsearch_request(:get, "_cat/indices?format=json&h=index").to_return_json, [
      { index: "ca_locals_v14" }
    ])

    stub_elasticsearch_reindex_request("articles")
    stub_elasticsearch_search_request("articles", [
      {"_id" => "135", "_source" => {"name" => "Hello World"}},
      {"_id" => "137", "_source" => {"name" => "Hello World"}}
    ])
  end

  # ... do your tests...
end
```

`stub_elasticsearch_search_request` accepts an array or records:

```ruby
RSpec.describe SomeClass do
  let(:articles) { create_list(:article, 5) }

  before do
    stub_elasticsearch_search_request("articles", articles)
  end

  # ... do your tests...
end
```

It allows to shim the total number of hits returned.

```ruby
RSpec.describe SomeClass do
  before do
    stub_elasticsearch_search_request("articles", [], total: 250)
  end

  # ... do your tests...
end
```

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
bundle exec standardrb
```

All of them can be run with:

```bash
bundle exec rake
```

## License & credits

Please see [LICENSE](https://github.com/mon-territoire/caoutsearch/blob/main/LICENSE) for further details.

Contributors: [./graphs/contributors](https://github.com/mon-territoire/caoutsearch/graphs/contributors)

