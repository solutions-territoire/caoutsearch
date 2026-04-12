---
title: Boolean
---

You can define a boolean filter using `as: :boolean`:

```ruby
class ArticleSearch < Caoutsearch::Search::Base
  filter :published, as: :boolean
end
```

The filter will transform input as booleans:

```ruby
Article.search(published: "true")
```
```json
{
  "query": { 
    "bool": { 
      "filter": [ 
        { "range": { "published": true }}
      ]
    }
  }
}
```

The following values will be casted as `false`:
```ruby
Article.search(published: false)
Article.search(published: 0)
Article.search(published: "0")
Article.search(published: "f")
Article.search(published: "false")
Article.search(published: "off")
```
```json
{
  "query": { 
    "bool": { 
      "filter": [ 
        { "range": { "published": false }}
      ]
    }
  }
}
```

Empty values (`nil`, `""`, `[]`) are ignored.
Any other values, will be casted as `true`:

```ruby
Article.search(published: true)
Article.search(published: 1)
Article.search(published: "1")
Article.search(published: "t")
Article.search(published: "true")
Article.search(published: "on")
Article.search(published: "whatever")
```
```json
{
  "query": { 
    "bool": { 
      "filter": [ 
        { "range": { "published": true }}
      ]
    }
  }
}
```
