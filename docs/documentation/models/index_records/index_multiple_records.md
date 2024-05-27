---
title: "Index multiple records"
order: 0
---

Import all your records or a restricted scope of records to Elastcisearch.

````ruby
Article.reindex
Article.where(published: true).reindex
````

You can update one or more properties. (see [Index Engines](/docs/indexes/properties/) to read more about properties):

````ruby
Article.reindex(:category)
Article.reindex(%i[category published_on])
````

When `reindex` is called without properties, it'll import the full document to ES.  
On the contrary, when properties are passed, it'll only update existing documents.  
You can control this behavior with the `method` argument.

````ruby
Article.where(id: 123).reindex(:category)
# ArticleIndex Reindex {"index":"articles","body":[{"update":{"_id":123}},{"doc":{"category":"blog"}}]}
# [Error] {"update"=>{"_index"=>"articles", "_id"=>"123", "status"=>404, "error"=>{"type"=>"document_missing_exception", …}}

Article.where(id: 123).reindex(:category, method: :index)
# ArticleIndex Reindex {"index":"articles","body":[{"index":{"_id":123}},{"category":"blog"}]}

Article.where(id: 123).reindex(method: :update)
# ArticleIndex Reindex {"index":"articles","body":[{"update":{"_id":123}},{"doc":{…}}]}
````