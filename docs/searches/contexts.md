---
title: Contexts
order: -5
---

Contexts allows to create search scopes independently of search criteria.
Because search criteria may comes from user inputs, contexts offers a way to force search scoping :

```ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_context :public do
    filters << { term: { published: true } }
  end
end

ArticleSearch.context(:public).search(params[:q])
```

Multiple contexts can be passed together or chained:

```ruby
ArticleSearch.context(:public, :blog)
ArticleSearch.context(:public).context(:blog)
```

Missing contexts doesn't raise an expection and are ignored.
It allows you to apply contexts to any searches, whether the context is implemented or not:

```ruby
class BlogController < ApplicationController
  def index
    @articles = ArticleSearch.context(current_context).search(params[:q])
    @tags = TagSearch.context(current_context).search(params[:q]) # TagSearch doesn't implement a "public" context
  end

  protected

  def current_context
    :public unless current_user&.admin?
  end
end
```
