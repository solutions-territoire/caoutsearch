---
title: Filters
order: -1
---

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
