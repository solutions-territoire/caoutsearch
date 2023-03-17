---
title: "Add Caoutsearch to your models"
order: 0
---

The simplest solution is to add `Caoutsearch::Model` to your model and the link the appropriate `Index` and/or `Search` engines:

```ruby
class Article < ActiveRecord::Base
  include Caoutsearch::Model

  index_with ArticleIndex
  search_with ArticleSearch
end
```

If you don't need your models to be `Indexable` and `Searchable`, you can include only one of the following two modules:

````ruby
class Article < ActiveRecord::Base
  include Caoutsearch::Model::Indexable

  index_with ArticleIndex
end
````
or
````ruby
class Article < ActiveRecord::Base
  include Caoutsearch::Model::Searchable

  search_with ArticleSearch
end
````

The modules can be safely included in the meta model `ApplicationRecord`.
Indexing & searching features are not available until you call `index_with` or `search_with`:

````ruby
class ApplicationRecord < ActiveRecord::Base
  include Caoutsearch::Model
end
````
