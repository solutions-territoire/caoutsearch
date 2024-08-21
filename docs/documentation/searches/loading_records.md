---
title: Loading records
order: -10
---

Use `records` to load model records.

The search engine will try to load records from a model using the same class name without `Search` the suffix:  
* `ArticleSearch` > `Article`
* `Blog::ArticleSearch` > `Blog::Article`

````ruby
ArticleSearch.new.records.first
# ArticleSearch Search (10ms / took 5ms)
# Article Load (9.6ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" IN (1, …
=> #<Article id: 1, …>
````

However, you can define an alternative model to load records. This might be helpful when using [single table inheritance](https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html).

````ruby
ArticleSearch.new.records(use: BlogArticle).first
# ArticleSearch Search (10ms / took 5ms)
# BlogArticle Load (9.6ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" IN (1, …
=> #<BlogArticle id: 1, …>
````

You can also define an alternative model at class level:

````ruby
class BlogArticleSearch < Caoutsearch::Search::Base
  self.model_name = "Article"

  default do
    query.filters << { term: { category: "blog" } }
  end
end

BlogArticleSearch.new.records.first
# BlogArticleSearch Search (10ms / took 5ms)
# Article Load (9.6ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" IN (1, …
=> #<Article id: 1, …>
````
