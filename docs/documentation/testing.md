---
title: Testing with Caoutsearch
order: -4
---

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