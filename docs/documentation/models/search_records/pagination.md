---
title: "Pagination"
order: -1
---

Search results can be paginated.
````ruby
search = Article.search("Quick brown fox").page(1).per(100)
search.current_page
=> 1

search.total_pages
=> 2546

> search.total_count
=> 254514
````