---
title: "Iterating results"
order: -3
---

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