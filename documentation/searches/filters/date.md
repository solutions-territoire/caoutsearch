You can define a date filter using `as: :date`:

```ruby
class ArticleSearch < Caoutsearch::Search::Base
  filter :published_on, as: :date
end
```

The filter will build a range query to match any [data field type](https://www.elastic.co/docs/reference/elasticsearch/mapping-reference/date):

```ruby
Article.search(published_on: Date.today)
```
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

The date filter accepts various types of date:
```ruby
Article.search(published_on: "2022-10-11")
Article.search(published_on: Date.today)
Article.search(published_on: Time.zone.now)
```

It also supports elasticsearch's date math:
```ruby
Article.search(published_on: "now-1h")
Article.search(published_on: "now+2w/d")
```

Finally, it accepts multiple ranges of arguments:

```ruby
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
