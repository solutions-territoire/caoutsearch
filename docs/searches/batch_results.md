---
title: "Batch results"
order: -11
---

Several methods are provided to loop batches of results.  
These methods are processing batches in the most efficient way: [PIT search_after](https://www.elastic.co/guide/en/elasticsearch/reference/current/paginate-search-results.html#search-after).

* `find_each_hit` to yield each hit returned by Elasticsearch.
* `find_hits_in_batches` to yield each batch of hits as returned by Elasticsearch.

You can also batch records from database : (see: [Loading records](/documentation/searches/loading_records.md))

* `find_each_record` to yield each record from your database.
* `find_records_in_batches` to yield each batch of records from the database.


Example:

```ruby
ArticleSearch.search(published: true).find_each_hit do |hit|
  hit.inspect
end
```

The `keep_alive` parameter tells Elasticsearch how long it should keep the point in time alive. Defaults to 1 minute.

```ruby
ArticleSearch.search(published: true).find_each_hit(keep_alive: "2h")
```

To specifies the size of the batches, use `per` chainable method or `batch_size` parameter. Defaults to 1000.

```ruby
ArticleSearch.search(published: true).find_hits_in_batches(batch_size: 500)
ArticleSearch.search(published: true).per(500).find_hits_in_batches
```
