---
title: "Delete documents"
order: -2
---

You can delete one or more documents.  
**Note**: it won't delete records from database, only from the ES indice.

````ruby
Article.delete_indexes
Article.where(id: 123).delete_indexed_documents
Article.find(123).delete_index
````

If a record is already deleted from the database, you can still delete its document.

````ruby
Article.delete_index(123)
````