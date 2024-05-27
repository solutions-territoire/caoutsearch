---
title: Transform aggregations
order: -8
---

When using [buckets aggregation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket.html) and/or [pipeline aggregation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-pipeline.html), the path to the expected values can get complicated and become subject to unexpected changes for a public API.

````ruby
ArticleSearch.aggregate(popular_tags_since: 1.month.ago).aggregations.popular_tags_since.published.buckets.pluck(:key)
=> ["Blog", "Tech", …]
````

Instead, you can define transformations to provide simpler access to aggregated data:

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_aggregation :popular_tags_since do |since|
    # …
  end

  transform_aggregation :popular_tags_since do |aggs|
    aggs.dig(:popular_tags_since, :published, :buckets).pluck(:key)
  end
end

ArticleSearch.aggregate(popular_tags_since: 1.month.ago).aggregations.popular_tags_since
=> ["Blog", "Tech", …]
````

You can also use transformations to combine multiple aggregations:

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_aggregation :blog_count,     { filter: { term: { category: "blog" } } }
  has_aggregation :archives_count, { filter: { term: { archived: true } } }

  transform_aggregation :stats, from: %i[blog_count archives_count] do |aggs|
    {
      blog_count:     aggs.dig(:blog_count, :doc_count),
      archives_count: aggs.dig(:archives, :doc_count)
    }
  end
end

ArticleSearch.aggregate(:stats).aggregations.stats
# ArticleSearch Search { "body": { "aggs": { "blog_count": {…}, "archives_count": {…}}}}
# ArticleSearch Search (10ms / took 5ms)
=> { blog_count: 124, archives_count: 2452 }
````

This is also usefull to unify the API between different search engines:

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_aggregation :popular_tags, {
    filter: { term: { published: true } },
    aggs: { published: { terms: { field: :tags, size: 10 } } }
  }

  transform_aggregation :popular_tags do |aggs|
    aggs.dig(:popular_tags, :published, :buckets).pluck(:key)
  end
end

class TagSearch < Caoutsearch::Search::Base
  has_aggregation :popular_tags, {
    terms: { field: "label", size: 20, order: { used_count: "desc" } }
  }

  transform_aggregation :popular_tags do |aggs|
    aggs.dig(:popular_tags, :buckets).pluck(:key)
  end
end

ArticleSearch.aggregate(:popular_tags).aggregations.popular_tags
=> ["Blog", "Tech", …]

TagSearch.aggregate(:popular_tags).aggregations.popular_tags
=> ["Tech", "Blog", …]
````

Transformations are performed on demand and result is memorized. That means:
- the result of transformation is not visible in the [Response::Aggregations](/docs/searches/responses) output.
- the block is called only once for the same search instance.

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_aggregation :popular_tags, {…}

  transform_aggregation :popular_tags do |aggs|
    tags       = aggs.dig(:popular_tags, :published, :buckets).pluck(:key)
    authorized = Tag.where(title: tags, authorize: true).pluck(:title)
    tags & authorized
  end
end

article_search = ArticleSearch.aggregate(:popular_tags)
=> #<ArticleSearch current_aggregations: [:popular_tags]>

article_search.aggregations
# ArticleSearch Search (10ms / took 5ms)
=> #<Caoutsearch::Response::Aggregations popular_tags=#<Caoutsearch::Response::Response doc_count=100 …

article_search.aggregations.popular_tags
# (10.2ms)  SELECT "tags"."title" FROM "tags" WHERE "tags"."title" IN …
=> ["Blog", "Tech", …]

article_search.aggregations.popular_tags
=> ["Blog", "Tech", …]

article_search.search("Tech").aggregations.popular_tags
# ArticleSearch Search (10ms / took 5ms)
# (10.2ms)  SELECT "tags"."title" FROM "tags" WHERE "tags"."title" IN …
=> ["Blog", "Tech", …]
````

Be careful to avoid using `aggregations.<aggregation_name>` inside a transformation block: it can lead to an infinite recursion.

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  transform_aggregation :popular_tags do
    aggregations.popular_tags.buckets.pluck("key")
  end
end

ArticleSearch.aggregate(:popular_tags).aggregations.popular_tags
Traceback (most recent call last):
      4: from app/searches/article_search.rb:3:in `block in <class:ArticleSearch>'
      3: from app/searches/article_search.rb:3:in `block in <class:ArticleSearch>'
      2: from app/searches/article_search.rb:3:in `block in <class:ArticleSearch>'
      1: from app/searches/article_search.rb:3:in `block in <class:ArticleSearch>'
SystemStackError (stack level too deep)
````

Instead, use the argument passed to the block: it's is a shortcut for `response.aggregations` which is a [Response::Reponse](/docs/searches/responses) and not a [Response::Aggregations](/docs/searches/responses).

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  transform_aggregation :popular_tags do |aggs|
    aggs.popular_tags.buckets.pluck("key")
  end
end

ArticleSearch.aggregate(:popular_tags).aggregations.popular_tags
=> ["Blog", "Tech", …]
````

One last helpful argument is `track_total_hits` which allows to perform calculations over aggregations using the `total_count` method without sending a second request.  
Take a look at [Total count](/docs/models/search_records/total_count) to understand why a second request could be performed.

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  aggregation :tagged, filter: { exist: "tag" }

  transform_aggregation :tagged_rate, from: :tagged, track_total_hits: true do |aggs|
    count = aggs.dig(:tagged, :doc_count)
    count.to_f / total_count
  end

  transform_aggregation :tagged_rate_without_track_total_hits, from: :tagged do |aggs|
    count = aggs.dig(:tagged, :doc_count)
    count.to_f / total_count
  end
end

ArticleSearch.aggregate(:tagged_rate).aggregations.tagged_rate
# ArticleSearch Search { "body": { "track_total_hits": true, "aggs": { "blog_count": {…}, "archives_count": {…}}}}
# ArticleSearch Search (10ms / took 5ms)
=> 0.95

ArticleSearch.aggregate(:tagged_rate_without_track_total_hits).aggregations.tagged_rate
# ArticleSearch Search { "body": { "aggs": { "blog_count": {…}, "archives_count": {…}}}}
# ArticleSearch Search (10ms / took 5ms)
# ArticleSearch Search { "body": { "track_total_hits": true, "aggs": { "blog_count": {…}, "archives_count": 
# ArticleSearch Search (10ms / took 5ms)
=> 0.95
````