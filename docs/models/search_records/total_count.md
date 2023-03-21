---
title: "Total count"
order: -2
---

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