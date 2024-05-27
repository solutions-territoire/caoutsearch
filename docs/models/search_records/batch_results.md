---
title: "Batch records"
order: -3
---

Several methods are provided to loop batches of records.  
You should first look how to batch results:

[!ref](/documentation/searches/batch_results.md)


Example:

```ruby
Article.search(published: true).find_each_record do |record|
  record.inspect
end
```

```ruby
Article.search(published: true).find_records_in_batches(batch_size: 500)
Article.search(published: true).per(500).find_records_in_batches
```