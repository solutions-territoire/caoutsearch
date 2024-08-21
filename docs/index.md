# Caoutsearch [\ˈkawt͡ˈsɝtʃ\\](http://ipa-reader.xyz/?text=ˈkawt͡ˈsɝtʃ)

<span>[![Gem Version](https://badge.fury.io/rb/caoutsearch.svg)](https://rubygems.org/gems/caoutsearch)</span> <span>
[![CI Status](https://github.com/solutions-territoire/caoutsearch/actions/workflows/ci.yml/badge.svg)](https://github.com/solutions-territoire/caoutsearch/actions/workflows/ci.yml)</span> <span>
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)</span> <span>
[![Maintainability](https://api.codeclimate.com/v1/badges/fbe73db3fd8be9a10e12/maintainability)](https://codeclimate.com/github/solutions-territoire/caoutsearch/maintainability)</span> <span>
[![Test Coverage](https://api.codeclimate.com/v1/badges/fbe73db3fd8be9a10e12/test_coverage)](https://codeclimate.com/github/solutions-territoire/caoutsearch/test_coverage)</span>

<span>[![JRuby](https://github.com/solutions-territoire/caoutsearch/actions/workflows/jruby.yml/badge.svg)](https://github.com/solutions-territoire/caoutsearch/actions/workflows/jruby.yml)</span> <span>
[![Truffle Ruby](https://github.com/solutions-territoire/caoutsearch/actions/workflows/truffle_ruby.yml/badge.svg)](https://github.com/solutions-territoire/caoutsearch/actions/workflows/truffle_ruby.yml)</span>

**!! Gem under development before public release !!**

Caoutsearch is a new Elasticsearch integration for Ruby and/or Rails.  
It provides a simple but powerful DSL to perform complex indexing and searching, while securely exposing search criteria to a public and chainable API, without overwhelming your models.

Caoutsearch only supports Elasticsearch 8.x right now.  
It is used in production in a robust application, updated and maintained for several years at [Solutions & Territoire](https://solutions-territoire.fr).

Caoutsearch was inspired by awesome gems such as [elasticsearch-rails](https://github.com/elastic/elasticsearch-rails) or [search_flip](https://github.com/mrkamel/search_flip).  
Depending on your search scenarios, they may better suite your needs.

## Overview

Caoutsearch let you create `Index` and `Search` classes to manipulate your data :

```ruby
class ArticleIndex < Caoutsearch::Index::Base
  property :title
  property :published_on
  property :tags

  def tags
    records.tags.public.map(&:to_s)
  end
end
```

```ruby
class ArticleSearch < Caoutsearch::Search::Base
  filter :title, as: :match
  filter :published_on, as: :date
  filter :tags

  has_aggregation :popular_tags, {
    filter: { term: { published: true } },
    aggs: {
      published: {
        terms: { field: :tags, size: 10 }
      }
    }
  }
end
```

You can then index your records

```ruby
ArticleIndex.reindex
```

Or search through them:

```ruby
ArticleSearch.search(published_on: [["now-1y", nil]]).aggregate(:popular_tags)
```
