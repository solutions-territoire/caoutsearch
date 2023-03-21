---
title: "Index single records"
order: -1
---

Import a single record.

````ruby
Article.find(123).update_index
````

You can update one or more properties. (see [Index Engines](/docs/indexes/properties/) to read more about properties):

````ruby
Article.find(123).update_index(:category)
Article.find(123).update_index(%i[category published_on])
````

You can verify if and how documents are indexed.  
If the document is missing in ES, it'll raise a `Elastic::Transport::Transport::Errors::NotFound`.

````ruby
Article.find(123).indexed_document
# Traceback (most recent call last):
#         1: from (irb):1
# Elastic::Transport::Transport::Errors::NotFound ([404] {"_index":"articles","_id":"123","found":false})

Article.find(123).update_index
Article.find(123).indexed_document
=> {"_index"=>"articles", "_id"=>"123", "_version"=>1"found"=>true, "_source"=>{…}}
````