---
title: Date
---

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