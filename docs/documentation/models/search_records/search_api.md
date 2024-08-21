---
title: "Search API"
order: 0
---

Searching is pretty simple.

````ruby
Article.search("Quick brown fox")
=> #<ArticleSearch current_criteria: ["Quick brown fox"]>
````

You can chain criteria and many other parameters:
````ruby
Article.search("Quick brown fox").search(published: true)
=> #<ArticleSearch current_criteria: ["Quick brown fox", {"published"=>true}]>

Article.search("Quick brown fox").order(:publication_date)
=> #<ArticleSearch current_criteria: ["Quick brown fox"], current_order: :publication_date>

Article.search("Quick brown fox").limit(100).offset(100)
=> #<ArticleSearch current_criteria: ["Quick brown fox"], current_limit: 100, current_offset: 100>

Article.search("Quick brown fox").page(1).per(100)
=> #<ArticleSearch current_criteria: ["Quick brown fox"], current_page: 1, current_limit: 100>

Article.search("Quick brown fox").aggregate(:tags).aggregate(:dates)
=> #<ArticleSearch current_criteria: ["Quick brown fox"], current_aggregations: [:tags, :dates]>>
````