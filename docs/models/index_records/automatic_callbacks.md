---
title: "Automatic callbacks"
order: -3
---

Callbacks are not provided by Caoutsearch but they are very easy to add:

````ruby
class Article < ApplicationRecord
  index_with ArticleIndex
  
  after_commit :update_index, on: %i[create update]
  after_commit :delete_index, on: %i[destroy]
end
````